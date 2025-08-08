import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl = "https://cotacao.onrender.com";
  String? _accessToken;
  DateTime? _tokenExpiry;

  Future<void> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        body: {'username': username, 'password': password},
      );

      if (response.statusCode == 200) {
        await _processTokenResponse(response.body);
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      await _clearAuthData();
      rethrow;
    }
  }

  Future<void> _processTokenResponse(String responseBody) async {
    final jsonResponse = jsonDecode(responseBody);

    if (jsonResponse['success'] == true) {
      _accessToken = jsonResponse['access_token'];
      _tokenExpiry = DateTime.now().add(
        Duration(minutes: jsonResponse['expires_in_minutes'] ?? 500),
      );

      await _saveAuthData();
    } else {
      throw Exception('Failed to obtain token');
    }
  }

  Future<void> _saveAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', _accessToken!);
    await prefs.setString('token_expiry', _tokenExpiry!.toIso8601String());
  }

  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('token_expiry');
    _accessToken = null;
    _tokenExpiry = null;
  }

  Future<bool> _isTokenExpired() async {
    if (_tokenExpiry == null) {
      final prefs = await SharedPreferences.getInstance();
      final expiryString = prefs.getString('token_expiry');
      if (expiryString != null) {
        _tokenExpiry = DateTime.parse(expiryString);
      }
    }
    return _tokenExpiry == null || _tokenExpiry!.isBefore(DateTime.now());
  }

  Future<void> _refreshToken() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': await _getStoredToken()}),
      );

      if (response.statusCode == 200) {
        await _processTokenResponse(response.body);
      } else {
        await _clearAuthData();
        throw Exception('Token refresh failed: ${response.statusCode}');
      }
    } catch (e) {
      await _clearAuthData();
      rethrow;
    }
  }

  Future<String?> _getStoredToken() async {
    if (_accessToken == null) {
      final prefs = await SharedPreferences.getInstance();
      _accessToken = prefs.getString('access_token');
    }
    return _accessToken;
  }

  Future<String> getValidToken() async {
    if (!(await _isTokenExpired())) {
      return _accessToken ?? (await _getStoredToken())!;
    }

    await _refreshToken();
    return _accessToken!;
  }

  Future<Map<String, dynamic>> authenticatedRequest(
    Future<http.Response> Function(String token) request,
  ) async {
    try {
      final token = await getValidToken();
      var response = await request(token);

      if (response.statusCode == 401) {
        await _refreshToken();
        final newToken = await getValidToken();
        response = await request(newToken);
      }

      if (response.statusCode == 200) {
        final responseBody = response.body;
        final jsonData = jsonDecode(responseBody);

        if (jsonData is! Map<String, dynamic>) {
          throw Exception('Resposta da API em formato inválido');
        }

        return jsonData.containsKey('data') ? jsonData['data'] : jsonData;
      } else {
        throw Exception('Request failed: ${response.statusCode}');
      }
    } catch (e) {
      await _clearAuthData();
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getStock(String ticker) async {
    try {
      final response = await authenticatedRequest(
        (token) => http.get(
          Uri.parse('$baseUrl/stock/${ticker.toUpperCase()}'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      if (response.isEmpty) {
        throw Exception('Dados da ação não encontrados');
      }

      return response;
    } catch (e) {
      throw Exception('Erro ao obter dados da ação: $e');
    }
  }

  Future<Map<String, dynamic>> calculateCompoundInterest(
    Map<String, dynamic> body,
  ) async {
    return await authenticatedRequest(
      (token) => http.post(
        Uri.parse('$baseUrl/calculation'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      ),
    );
  }
}

import 'package:dlsystem/login_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthMiddleware extends RouteObserver<PageRoute<dynamic>> {
  Future<bool> _isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token') != null;
  }

  @override
  void didPush(Route route, Route? previousRoute) async {
    super.didPush(route, previousRoute);

    if (route.settings.name != LoginPage.routeName) {
      final isAuthenticated = await _isAuthenticated();
      if (!isAuthenticated) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(
            route.navigator!.context,
            LoginPage.routeName,
          );
        });
      }
    }
  }
}

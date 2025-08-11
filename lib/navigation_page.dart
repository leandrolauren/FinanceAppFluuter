import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'calculator_page.dart';
import 'stock_page.dart';

class NavigationPage extends StatelessWidget {
  static const String routeName = '/home';
  const NavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Finance App'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('access_token');
              await prefs.remove('token_expiry');
              await prefs.remove('tickers');
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StockPage()),
                );
              },
              child: Text('Ações'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CalculatorPage()),
                );
              },
              child: Text('Calculadora Juros Compostos'),
            ),
          ],
        ),
      ),
    );
  }
}

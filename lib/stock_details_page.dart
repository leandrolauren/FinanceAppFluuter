import 'package:flutter/material.dart';

class StockDetailsPage extends StatelessWidget {
  final Map<String, dynamic> stockData;

  const StockDetailsPage({super.key, required this.stockData});

  @override
  Widget build(BuildContext context) {
    final variation = stockData['Variation'] ?? 0.0;
    final variationColor = variation >= 0 ? Colors.green : Colors.red;

    return Scaffold(
      appBar: AppBar(title: Text(stockData['Name'] ?? 'Detalhes')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              stockData['Name'] ?? '',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text("Setor: ${stockData['Sector']}"),
            Text("Indústria: ${stockData['Industry']}"),
            const SizedBox(height: 20),
            Text(
              "Preço Atual: \$${stockData['Actual Price']}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text("Fechamento Anterior: \$${stockData['Previous Close']}"),
            Text(
              "Variação: ${variation.toStringAsFixed(2)}%",
              style: TextStyle(
                color: variationColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text("Market Cap: ${stockData['Market Cap']}"),
            Text("P/E: ${stockData['P/E']}"),
            Text("EBITDA: ${stockData['EBITDA']}"),
            Text("Margem Bruta: ${stockData['Gross Margin']}%"),
            Text("Margem Líquida: ${stockData['Net Margin']}%"),
            Text(
              "Dividendo: ${stockData['Dividend Rate']} (${stockData['Dividend Yield']}%)",
            ),
            const SizedBox(height: 20),
            Text(
              stockData['Description'] ?? '',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}

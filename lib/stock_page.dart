import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services.dart';
import 'stock_details_page.dart';

class StockPage extends StatefulWidget {
  @override
  _StockPageState createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  final api = ApiService();
  final TextEditingController _tickerController = TextEditingController();
  List<Map<String, dynamic>> stocks = [];
  bool loading = true;
  String? ticker;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ticker = ModalRoute.of(context)?.settings.arguments as String?;
  }

  @override
  void initState() {
    super.initState();
    _initStocks();
  }

  Future<void> _initStocks() async {
    await loadSavedStocks();
    setState(() {
      loading = false;
    });
  }

  Future<void> loadSavedStocks() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTickers = prefs.getStringList('tickers') ?? [];

    List<Map<String, dynamic>> loadedStocks = [];

    for (var t in savedTickers) {
      try {
        final data = await api.getStock(t);
        loadedStocks.add(data);
      } catch (_) {}
    }

    setState(() {
      stocks = loadedStocks;
    });
  }

  Future<void> addStock(String ticker) async {
    ticker = ticker.trim().toUpperCase();
    final prefs = await SharedPreferences.getInstance();
    final savedTickers = prefs.getStringList('tickers') ?? [];

    if (savedTickers.contains(ticker)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ticker já adicionado')));
      return;
    }

    setState(() => loading = true);

    try {
      final data = await api.getStock(ticker);
      setState(() => stocks.add(data));

      savedTickers.add(ticker);
      await prefs.setStringList('tickers', savedTickers);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro: $e')));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ações')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _tickerController,
              decoration: const InputDecoration(labelText: 'Ticker'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final ticker = _tickerController.text;
                if (ticker.isNotEmpty) {
                  await addStock(ticker);
                  _tickerController.clear();
                }
              },
              child: const Text('Buscar Cotação'),
            ),
            const SizedBox(height: 20),
            loading
                ? const CircularProgressIndicator()
                : Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.1,
                          ),
                      itemCount: stocks.length,
                      itemBuilder: (context, index) {
                        final stock = stocks[index];
                        final variation = stock['Variation'] ?? 0;
                        final isPositive = variation >= 0;

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    StockDetailsPage(stockData: stock),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Nome e ticker
                                  Text(
                                    stock['Name'] ?? stock['Ticker'] ?? '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // Preço atual
                                  Text(
                                    "R\$ ${stock['Actual Price']?.toStringAsFixed(2) ?? '--'}",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueAccent,
                                    ),
                                  ),

                                  // Variação %
                                  Row(
                                    children: [
                                      Icon(
                                        isPositive
                                            ? Icons.arrow_upward
                                            : Icons.arrow_downward,
                                        color: isPositive
                                            ? Colors.green
                                            : Colors.red,
                                        size: 18,
                                      ),
                                      Text(
                                        "${variation.toStringAsFixed(2)}%",
                                        style: TextStyle(
                                          color: isPositive
                                              ? Colors.green
                                              : Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const Spacer(),

                                  // Setor e P/L
                                  Text(
                                    "Setor: ${stock['Sector'] ?? '--'}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    "P/L: ${stock['P/E']?.toStringAsFixed(2) ?? '--'}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

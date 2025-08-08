import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'services.dart';
import 'package:data_table_2/data_table_2.dart';

class CalculatorPage extends StatefulWidget {
  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final api = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _initialValueController = TextEditingController(text: '1000');
  final _monthlyContributionController = TextEditingController(text: '100');
  final _annualInterestController = TextEditingController(text: '12');
  final _monthsController = TextEditingController(text: '12');

  bool loading = false;
  Map<String, dynamic>? result;

  final NumberFormat currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );

  Future<void> calculate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);

    try {
      final data = {
        "initial_value": double.parse(_initialValueController.text),
        "monthly_contribution": double.parse(
          _monthlyContributionController.text,
        ),
        "annual_interest": double.parse(_annualInterestController.text),
        "months": int.parse(_monthsController.text),
      };

      final res = await api.calculateCompoundInterest(data);
      setState(() => result = res);
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
      appBar: AppBar(title: const Text('Calculadora de Juros Compostos')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(_initialValueController, 'Valor Inicial'),
              _buildTextField(_monthlyContributionController, 'Aporte Mensal'),
              _buildTextField(_annualInterestController, 'Juros Anual (%)'),
              _buildTextField(_monthsController, 'Meses', isInt: true),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: loading ? null : calculate,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Calcular', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 30),
              if (result != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildInfoCard(
                      'Investido',
                      result!['amount_invested'],
                      Colors.blue,
                    ),
                    _buildInfoCard(
                      'Juros',
                      result!['total_interest'],
                      Colors.green,
                    ),
                    _buildInfoCard(
                      'Total',
                      result!['total_value'],
                      Colors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Text(
                  'Evolução mês a mês:',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[100],
                  ),
                  child: SizedBox(
                    height: 400,
                    child: DataTable2(
                      headingRowColor: MaterialStateProperty.all(
                        Colors.grey[300],
                      ),
                      columnSpacing: 20,
                      horizontalMargin: 12,
                      minWidth: 600,
                      columns: const [
                        DataColumn2(label: Text('Mês'), size: ColumnSize.S),
                        DataColumn2(
                          label: Text('Investido'),
                          size: ColumnSize.M,
                        ),
                        DataColumn2(label: Text('Juros'), size: ColumnSize.M),
                        DataColumn2(label: Text('Total'), size: ColumnSize.M),
                      ],
                      rows: List<DataRow>.from(
                        (result!['months'] as List).map(
                          (m) => DataRow(
                            cells: [
                              DataCell(Text(m['Month'].toString())),
                              DataCell(
                                Text(
                                  currencyFormat.format(m['Amount Invested']),
                                ),
                              ),
                              DataCell(
                                Text(
                                  currencyFormat.format(m['Interest Amount']),
                                ),
                              ),
                              DataCell(
                                Text(
                                  currencyFormat.format(m['Accumulated Total']),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                Text(
                  'Gráfico de Crescimento',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  height: 250,
                  child: CompoundChart(months: result!['months']),
                ),
                const SizedBox(height: 30),
                Text(
                  'Investido x Juros',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  height: 200,
                  child: InvestedVsInterestBarChart(
                    invested: result!['amount_invested'],
                    interest: result!['total_interest'],
                    currencyFormat: currencyFormat,
                  ),
                ),

                const SizedBox(height: 30),
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 800) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Distribuição Investido x Juros '
                                      '(${currencyFormat.format(result!['amount_invested'] + result!['total_interest'])})',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    SizedBox(
                                      height: 200,
                                      child: InvestmentPieChart(
                                        invested: result!['amount_invested'],
                                        interest: result!['total_interest'],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Evolução Acumulada '
                                      '(${currencyFormat.format(result!['amount_invested'] + result!['total_interest'])})',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    SizedBox(
                                      height: 200,
                                      child: AccumulatedAreaChart(
                                        months: result!['months'],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Distribuição Investido x Juros '
                                    '(${currencyFormat.format(result!['amount_invested'] + result!['total_interest'])})',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  SizedBox(
                                    height: 200,
                                    child: InvestmentPieChart(
                                      invested: result!['amount_invested'],
                                      interest: result!['total_interest'],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Evolução Acumulada '
                                    '(${currencyFormat.format(result!['amount_invested'] + result!['total_interest'])})',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  SizedBox(
                                    height: 200,
                                    child: AccumulatedAreaChart(
                                      months: result!['months'],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
                const SizedBox(height: 30),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildTextField(
  TextEditingController controller,
  String label, {
  bool isInt = false,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: (v) => v == null || v.isEmpty ? 'Informe $label' : null,
    ),
  );
}

Widget _buildInfoCard(String title, double value, Color color) {
  var currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  return Expanded(
    child: Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              currencyFormat.format(value),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    ),
  );
}

class CompoundChart extends StatelessWidget {
  final List months;
  const CompoundChart({required this.months, super.key});

  @override
  Widget build(BuildContext context) {
    final spotsTotal = months
        .map<FlSpot>(
          (m) => FlSpot(
            (m['Month'] as num).toDouble(),
            (m['Accumulated Total'] as num).toDouble(),
          ),
        )
        .toList();

    final spotsInvested = months
        .map<FlSpot>(
          (m) => FlSpot(
            (m['Month'] as num).toDouble(),
            (m['Amount Invested'] as num).toDouble(),
          ),
        )
        .toList();

    return LineChart(
      LineChartData(
        backgroundColor: Colors.white,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (spotsTotal.last.y / 5),
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) => Text(
                NumberFormat.compactCurrency(
                  locale: 'pt_BR',
                  symbol: 'R\$',
                ).format(value),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: (months.length / 6).floorToDouble(),
              getTitlesWidget: (value, meta) => Text(
                '${value.toInt()}m',
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.black87,
            getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
              final label = spot.barIndex == 0 ? 'Total' : 'Investido';
              return LineTooltipItem(
                '$label\n${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(spot.y)}',
                const TextStyle(color: Colors.white, fontSize: 12),
              );
            }).toList(),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: months.length.toDouble(),
        lineBarsData: [
          LineChartBarData(
            spots: spotsTotal,
            isCurved: true,
            gradient: LinearGradient(colors: [Colors.green, Colors.lightGreen]),
            barWidth: 3,
            dotData: FlDotData(show: false),
          ),
          LineChartBarData(
            spots: spotsInvested,
            isCurved: true,
            gradient: LinearGradient(colors: [Colors.blue, Colors.lightBlue]),
            barWidth: 3,
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}

class InvestedVsInterestBarChart extends StatelessWidget {
  final double invested;
  final double interest;
  final NumberFormat currencyFormat;

  const InvestedVsInterestBarChart({
    required this.invested,
    required this.interest,
    required this.currencyFormat,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.black87,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final label = group.x == 0 ? 'Investido' : 'Juros';
              return BarTooltipItem(
                '$label\n${currencyFormat.format(rod.toY)}',
                const TextStyle(color: Colors.white, fontSize: 12),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  value.toInt() == 0 ? 'Investido' : 'Juros',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: invested,
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.lightBlue],
                ),
                width: 40,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: interest,
                gradient: LinearGradient(
                  colors: [Colors.green, Colors.lightGreen],
                ),
                width: 40,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class InvestmentPieChart extends StatelessWidget {
  final double invested;
  final double interest;

  const InvestmentPieChart({
    super.key,
    required this.invested,
    required this.interest,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'pt_BR');
    final total = invested + interest;

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: [
          PieChartSectionData(
            color: Colors.blue,
            value: invested,
            title:
                '${(invested / total * 100).toStringAsFixed(1)}%\n${currencyFormat.format(invested)}',
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            color: Colors.green,
            value: interest,
            title:
                '${(interest / total * 100).toStringAsFixed(1)}%\n${currencyFormat.format(interest)}',
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class AccumulatedAreaChart extends StatelessWidget {
  final List months;
  const AccumulatedAreaChart({required this.months, super.key});

  @override
  Widget build(BuildContext context) {
    final spots = months
        .map<FlSpot>(
          (m) => FlSpot(
            (m['Month'] as num).toDouble(),
            (m['Accumulated Total'] as num).toDouble(),
          ),
        )
        .toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient: LinearGradient(
              colors: [Colors.purple, Colors.purpleAccent],
            ),
            barWidth: 3,
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [Colors.purple.withOpacity(0.3), Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

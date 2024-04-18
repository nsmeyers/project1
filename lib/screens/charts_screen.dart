import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:project1/models/models.dart';

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({Key? key}) : super(key: key);

  @override
  _ChartsScreenState createState() => _ChartsScreenState();
}

enum ChartType { bar, pie }

class _ChartsScreenState extends State<ChartsScreen> {
  late Future<Map<String, double>> totalsFuture;
  ChartType _selectedChart = ChartType.bar; // Default chart type

  @override
  void initState() {
    super.initState();
    totalsFuture = fetchAndCalculateTotals();
  }

  Future<Map<String, double>> fetchAndCalculateTotals() async {
    List<Transaction> transactions = await Transaction.fetchTransactions();
    double totalIncoming = 0.0;
    double totalOutgoing = 0.0;
    double netTotal = 0.0;

    for (var transaction in transactions) {
      if (transaction.direction == "Incoming") {
        totalIncoming += transaction.amount ?? 0.0;
      } else if (transaction.direction == "Outgoing") {
        totalOutgoing += transaction.amount ?? 0.0;
      }
    }
    netTotal = totalIncoming + totalOutgoing; // Correct calculation for net total

    return {'TotalIncoming': totalIncoming, 'TotalOutgoing': totalOutgoing, 'NetTotal': netTotal};
  }

  Widget buildBanner(Map<String, double> totals) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.0),
      color: Colors.blueGrey[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            'Total Incoming: \$${totals['TotalIncoming']?.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const SizedBox(height: 10),
          Text(
            'Total Outgoing: \$${totals['TotalOutgoing']?.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
          ),
          const SizedBox(height: 10),
          Text(
            'Net Total: \$${totals['NetTotal']?.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Spending Overview", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[900],
      ),
      body: Column(
        children: [
          FutureBuilder<Map<String, double>>(
            future: totalsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  return Column(

                    children: [
                      buildBanner(snapshot.data!),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Radio<ChartType>(
                            value: ChartType.bar,
                            groupValue: _selectedChart,
                            onChanged: (ChartType? value) {
                              setState(() {
                                _selectedChart = value!;
                              });
                            },
                            activeColor: Colors.grey[900], // Set the active color
                            fillColor: MaterialStateProperty.all(Colors.grey[900]),
                          ),
                          const Text('Bar Chart'),
                          Radio<ChartType>(
                            value: ChartType.pie,
                            groupValue: _selectedChart,
                            onChanged: (ChartType? value) {
                              setState(() {
                                _selectedChart = value!;
                              });
                            },
                            activeColor: Colors.grey[900], // Set the active color
                            fillColor: MaterialStateProperty.all(Colors.grey[900]),
                          ),
                          const Text('Pie Chart'),
                        ],
                      ),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
              }
              return const CircularProgressIndicator();
            },
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(8),
              child: _selectedChart == ChartType.bar ? _buildBarChart() : _buildPieChart(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    // Prepare your data for the chart
    return BarChart(
      BarChartData(
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(toY: 10, color: Colors.green), // Adjusted from 'y' to 'toY'
              BarChartRodData(toY: 5, color: Colors.red), // Adjusted from 'y' to 'toY'
            ],
            //showingTooltipIndicators: [0, 1],
          ),
          // Add more groups as needed based on your data
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    // Example data, replace with real data preparation logic
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(value: 60, color: Colors.green, title: 'Type A'),
          PieChartSectionData(value: 40, color: Colors.red, title: 'Type B'),
        ],
      ),
    );
  }
}

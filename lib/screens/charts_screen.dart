import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:project1/models/models.dart';  // Ensure this path is correct.

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({Key? key}) : super(key: key);

  @override
  _ChartsScreenState createState() => _ChartsScreenState();
}

enum ChartType { bar, pie }

class _ChartsScreenState extends State<ChartsScreen> {
  late Future<Map<String, double>> pieChartDataFuture;
  late Future<Map<String, Map<String, double>>> barChartDataFuture;

  @override
  void initState() {
    super.initState();
    pieChartDataFuture = loadDataForPieChart();
    barChartDataFuture = loadDataForBarChart();
    totalsFuture = fetchAndCalculateTotals();
  }

  Future<Map<String, double>> loadDataForPieChart() async {
    List<Transaction> transactions = await Transaction.fetchTransactions();
    return Transaction.aggregateByType(transactions);
  }

  Future<Map<String, Map<String, double>>> loadDataForBarChart() async {
    List<Transaction> transactions = await Transaction.fetchTransactions();
    return Transaction.aggregateByMonth(transactions);
  }
  late Future<Map<String, double>> totalsFuture;
  ChartType _selectedChart = ChartType.bar; // Default chart type

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
                          const Text('Credit/Debit'),
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
                          const Text('Transaction Type'),
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

  Future<void> loadDataForCharts() async {
    List<Transaction> transactions = await Transaction.fetchTransactions();
    Map<String, double> typeData = Transaction.aggregateByType(transactions);  // Not currently used in the chart
    Map<String, Map<String, double>> monthlyData = Transaction.aggregateByMonth(transactions);
    setState(() {
      barChartDataFuture = Future.value(monthlyData);  // Update the future with new data
    });
  }
  String formatK(double value) {
    return "${(value / 1000).toStringAsFixed(1)}K";
  }

  Widget _buildBarChart() {
    return FutureBuilder<Map<String, Map<String, double>>>(

    future: barChartDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            var data = snapshot.data!;
            var barGroups = <BarChartGroupData>[];
            List<String> days = data.keys.toList();
            days.sort((a, b) => DateFormat('dd-MM').parse(a).compareTo(DateFormat('dd-MM').parse(b)));

            int index = 0;
            double maxY = 0;  // We'll calculate max Y
            double minY = 0;  // We'll calculate min Y

            // Calculate max and min Y values
            for (var values in data.values) {
              maxY = max(maxY, values['Incoming'] ?? 0);
              minY = min(minY, values['Outgoing'] ?? 0);
            }

            // Ensure that max and min Y are rounded to the nearest 5000 for nice graph steps
            maxY = (maxY / 5000).ceil() * 5000;
            minY = (minY / 5000).floor() * 5000; // This will be negative

            for (var day in days) {
              var values = data[day]!;
              barGroups.add(BarChartGroupData(
                x: index++,
                barRods: [
                  BarChartRodData(toY: values['Incoming'] ?? 0, color: Colors.green),
                  BarChartRodData(toY: values['Outgoing'] ?? 0, color: Colors.red),
                ],
              ));
            }

            return BarChart(

            BarChartData(
                maxY: maxY,
                minY: minY,
                barGroups: barGroups,
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        if (value.toInt() < days.length) {
                          return RotatedBox(
                            quarterTurns: 1, // Rotates the text 270 degrees
                            child: Text(
                              days[value.toInt()],
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10),
                            ),
                          );
                        }
                        return Text('');
                      },
                      reservedSize: 32,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(formatK(value), style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12));
                      },
                      interval: 5000, // Setting interval as 5000 units
                      reservedSize: 40,
                    ),
                  ),
                ),
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: false),
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Error loading bar chart data: ${snapshot.error}');
          }
        }
        return CircularProgressIndicator();
      },
    );
  }


  Widget _buildPieChart() {
    return FutureBuilder<Map<String, double>>(
      future: pieChartDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            List<PieChartSectionData> sections = snapshot.data!.entries.map((entry) {
              return PieChartSectionData(
                value: entry.value,
                color: Colors.primaries[snapshot.data!.keys.toList().indexOf(entry.key) % Colors.primaries.length],
                title: entry.key,
                radius: 200,
                titleStyle: TextStyle(
                    fontSize:12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFFFFFF)
                ),
                titlePositionPercentageOffset: 0.55,
              );
            }).toList();

            return PieChart(PieChartData(sections: sections));
          } else if (snapshot.hasError) {
            return Text('Error loading pie chart data: ${snapshot.error}');
          }
        }
        return CircularProgressIndicator();
      },
    );
  }

}

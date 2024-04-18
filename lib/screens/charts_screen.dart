import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({super.key});

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Spending Overview",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[900],
      ),
      body: Container(
        color: Colors.blue,
        child: BarChart(
          BarChartData(barGroups: []
              // read about it in the BarChartData section
              ),
        ),
      ),
    );
  }
}

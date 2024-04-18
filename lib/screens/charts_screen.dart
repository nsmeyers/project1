import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:project1/models/models.dart';

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({Key? key}) : super(key: key);

  @override
  _ChartsScreenState createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  late Future<Map<String, double>> totalsFuture;

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
    netTotal = totalIncoming + totalOutgoing;

    return {'TotalIncoming': totalIncoming, 'TotalOutgoing': totalOutgoing, 'NetTotal': netTotal};
  }

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
      body: Column(
        children: [
          FutureBuilder<Map<String, double>>(
            future: totalsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  return buildBanner(snapshot.data!);
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
              }
              return LinearProgressIndicator();
            },
          ),
          Expanded(
            child: Container(
              // Placeholder for additional UI components or charts
            ),
          ),
        ],
      ),
    );
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
}


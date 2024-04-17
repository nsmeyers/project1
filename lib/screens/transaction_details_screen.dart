import 'package:flutter/material.dart';
import 'package:project1/models.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailsScreen({Key? key, required this.transaction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction Details'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Transaction ID: ${transaction.transactionId ?? 'N/A'}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Amount: ${transaction.amount ?? 'N/A'}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('Direction: ${transaction.direction ?? 'N/A'}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('Type: ${transaction.type ?? 'N/A'}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('Status: ${transaction.status ?? 'N/A'}', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

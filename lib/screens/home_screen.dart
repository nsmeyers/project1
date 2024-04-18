import 'package:flutter/material.dart';
import 'package:project1/screens/transaction_details_screen.dart';

import '../models/models.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Home",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[900],
      ),
      body: FutureBuilder<List<Transaction>>(
        future: Transaction.fetchTransactions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          List<Transaction> data = snapshot.data!;
          if (data.isEmpty) {
            return const Center(child: Text('Error Fetching Data'));
          }
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              Transaction transaction = data[index];
              return ListTile(
                title: Text(
                  'Amount: \$${transaction.amount ?? 'N/A'} | Date: ${transaction.date ?? 'N/A'}',
                ),
                trailing: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.favorite),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => TransactionDetailsScreen(
                        transaction: transaction,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

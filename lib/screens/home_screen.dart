import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  Future<List<Transaction>> fetchTransactions() async {
    final response = await http.get(Uri.parse('https://my.api.mockaroo.com/account.json?key=fbb1c1a0'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Transaction.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load transactions from API');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: [
          FutureBuilder<List<Transaction>>(
            future: fetchTransactions(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  List<Transaction> data = snapshot.data!;
                  // Check if data is empty or all items are essentially null
                  bool hasValidData = data.any((transaction) => transaction.isValid());
                  if (!hasValidData) {
                    return Center(child: Text('Error Fetching Data'));
                  }
                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text('Amount: \$${data[index].amount ?? 'N/A'} | Date: ${data[index].date ?? 'N/A'} | Type: ${data[index].type ?? 'N/A'} | Status: ${data[index].status ?? 'N/A'} | Transaction ID: ${data[index].transactionId ?? 'N/A'}'),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error Fetching Data"));
                }
              }
              return const CircularProgressIndicator();
            },
          ),
          Container(
            color: Colors.blue,
            child: const Center(
              child: Text('Page 2'),
            ),
          ),
          Container(
            color: Colors.green,
            child: const Center(
              child: Text('Page 3'),
            ),
          ),
        ],
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Transactions",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Spending Overview",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          )
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.ease,
            );
          });
        },
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class Transaction {
  final int? userId;
  final int? transactionId;
  final String? type;
  final double? amount;
  final String? status;
  final String? date;

  Transaction({
    this.userId,
    this.transactionId,
    this.type,
    this.amount,
    this.status,
    this.date,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      userId: json['UserID'] as int?,
      transactionId: json['TransactionID'] as int?,
      type: json['TransactionType'] as String?,
      amount: (json['Amount'] as num?)?.toDouble(),
      status: json['Status'] as String?,
      date: json['Date'] as String?,
    );
  }

  bool isValid() {
    return userId != null || transactionId != null || amount != null || type != null || status != null || date != null;
  }
}


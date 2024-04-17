import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:project1/functions/firebase_functions.dart';
import 'package:project1/models.dart';
import 'package:project1/screens/profile_screen.dart';
import 'package:project1/screens/transaction_details_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  Future<List<Transaction>> fetchTransactions() async {
    final response = await http.get(
        Uri.parse('https://my.api.mockaroo.com/account.json?key=fbb1c1a0'));

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
                  if (data.isEmpty) {
                    return const Center(child: Text('Error Fetching Data'));
                  }
                  SharedPreferences.getInstance().then((prefs) async {
                    int? userId = prefs.getInt('id');
                    return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        Transaction transaction = data[index];
                        if (transaction.userId == userId) {
                          return ListTile(
                            title: Text(
                              'Amount: \$${transaction.amount ?? 'N/A'} | Date: ${transaction.date ?? 'N/A'}',
                            ),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      TransactionDetailsScreen(
                                    transaction: transaction,
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      },
                    );
                  });
                } else if (snapshot.hasError) {
                  return const Center(child: Text("Error Fetching Data"));
                }
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
          Container(
            color: Colors.blue,
            child: BarChart(
              BarChartData(barGroups: []
                  // read about it in the BarChartData section
                  ),
            ),
          ),
          const ProfileScreen(),
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

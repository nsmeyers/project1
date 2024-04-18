import 'package:flutter/material.dart';
import 'package:project1/screens/transaction_details_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.user,
  });

  final AppUser user;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic> _userFavorites = {};

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    widget.user.getUserFavorites().then((docs) {
      setState(() {
        _userFavorites = docs;
      });
    });
  }

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
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.home)),
                Tab(
                  icon: Icon(Icons.favorite),
                )
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  FutureBuilder<List<Transaction>>(
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
                          bool isFavorite = _userFavorites.keys
                              .contains(transaction.transactionId.toString());

                          return ListTile(
                            title: Text(
                              'Amount: \$${transaction.amount ?? 'N/A'} | Date: ${transaction.date ?? 'N/A'}',
                            ),
                            trailing: IconButton(
                              onPressed: () async {
                                if (isFavorite) {
                                  widget.user.deleteUserFavorites(
                                      transaction.transactionId.toString());
                                  setState(() {
                                    _userFavorites.remove(
                                        transaction.transactionId.toString());
                                  });
                                } else {
                                  widget.user
                                      .saveUserFavorites(transaction.toJson());
                                  setState(() {
                                    _userFavorites[transaction.transactionId
                                        .toString()] = transaction;
                                  });
                                }
                              },
                              icon: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isFavorite ? Colors.red : null,
                              ),
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
                        },
                      );
                    },
                  ),
                  FutureBuilder<List<Transaction>>(
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
                        itemCount: _userFavorites.length,
                        itemBuilder: (context, index) {
                          Transaction transaction = data[index];
                          bool isFavorite = _userFavorites.keys
                              .contains(transaction.transactionId.toString());

                          if (isFavorite) {
                            return ListTile(
                              title: Text(
                                'Amount: \$${transaction.amount ?? 'N/A'} | Date: ${transaction.date ?? 'N/A'}',
                              ),
                              trailing: IconButton(
                                onPressed: () async {
                                  if (isFavorite) {
                                    widget.user.deleteUserFavorites(
                                        transaction.transactionId.toString());
                                    setState(() {
                                      _userFavorites.remove(
                                          transaction.transactionId.toString());
                                    });
                                  } else {
                                    widget.user.saveUserFavorites(
                                        transaction.toJson());
                                    setState(() {
                                      _userFavorites[transaction.transactionId
                                          .toString()] = transaction;
                                    });
                                  }
                                },
                                icon: Icon(
                                  isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isFavorite ? Colors.red : null,
                                ),
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
                          } else {
                            return const SizedBox();
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

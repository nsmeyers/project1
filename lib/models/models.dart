import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class Transaction {
  final int? userId;
  final int? transactionId;
  final String? type;
  final double? amount;
  final String? status;
  final String? date;
  final String? direction;
  final bool isFavorite = false;


  Transaction({
    this.userId,
    this.transactionId,
    this.type,
    this.amount,
    this.status,
    this.date,
    this.direction,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {

    double? adjustedAmount = json['Amount'] is int
        ? (json['Amount'] as int).toDouble()
        : json['Amount'] as double?;

    // Adjust the amount if the direction is 'Outgoing'
    if (json['Direction'] == 'Outgoing') {
      adjustedAmount = -(adjustedAmount ?? 0.0);
    }

    return Transaction(
      userId: json['UserID'] as int?,
      transactionId: json['TransactionID'] as int?,
      type: json['TransactionType'] as String?,
      amount: adjustedAmount,
      status: json['Status'] as String?,
      date: json['Date'] as String?,
      direction: json['Direction'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'UserID': userId,
      'TransactionID': transactionId,
      'TransactionType': type,
      'Amount': amount,
      'Status': status,
      'Date': date,
      'Direction': direction,
    };
  }

  bool isValid() {
    // Define validity check conditions here
    return userId != null &&
        transactionId != null &&
        type != null &&
        amount != null &&
        status != null &&
        date != null &&
        direction != null;
  }

  static Future<List<Transaction>> fetchTransactions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachedData = prefs.getString('transactions');
    int? userId = prefs.getInt("id");

    List<Transaction> transactions = [];

    if (cachedData != null) {
      print("Cached data");
      Iterable l = json.decode(cachedData);
      transactions =
          List<Transaction>.from(l.map((model) => Transaction.fromJson(model)));
    } else {
      print("Api data");
      final response = await http.get(
          Uri.parse('https://my.api.mockaroo.com/account.json?key=fbb1c1a0'));
      if (response.statusCode == 200) {
        await prefs.setString('transactions', response.body);
        Iterable l = json.decode(response.body);
        transactions = List<Transaction>.from(
            l.map((model) => Transaction.fromJson(model)));
      } else {
        throw Exception('Failed to load transactions from API');
      }
    }

    // Filter transactions based on userId
    print('User ID from shared preferences: $userId');
    transactions = transactions
        .where((transaction) => transaction.userId == userId)
        .toList();
    print('Transactions for User ID $userId: ${transactions.length}');

    // Validate each transaction and filter out invalid ones

    Map<String, List<double>> organizeChartData(List<Transaction> transactions) {
      double totalIncoming = 0;
      double totalOutgoing = 0;
      Map<String, double> typeCounts = {};

      for (var transaction in transactions) {
        if (transaction.direction == "Incoming") {
          totalIncoming += transaction.amount ?? 0;
        } else if (transaction.direction == "Outgoing") {
          totalOutgoing += transaction.amount ?? 0;
        }
        typeCounts[transaction.type ?? 'Unknown'] = (typeCounts[transaction.type ?? 'Unknown'] ?? 0) + 1;
      }

      return {
        'totals': [totalIncoming, totalOutgoing],
        'typeCounts': typeCounts.entries.map((entry) => entry.value).toList(),
      };
    }

    return transactions.where((transaction) => transaction.isValid()).toList();

  }

  static Map<String, double> aggregateByType(List<Transaction> transactions) {
    Map<String, double> typeCounts = {};
    for (var transaction in transactions) {
      if (transaction.isValid()) {
        typeCounts[transaction.type ?? 'Unknown'] = (typeCounts[transaction.type ?? 'Unknown'] ?? 0) + 1;
      }
    }
    return typeCounts;
  }

  static Map<String, Map<String, double>> aggregateByMonth(List<Transaction> transactions) {
    Map<String, Map<String, double>> dailyData = {};
    DateFormat dateFormat = DateFormat('dd/MM/yyyy'); // Date format for parsing

    for (var transaction in transactions) {
      if (transaction.isValid()) {
        DateTime date;
        try {
          date = dateFormat.parse(transaction.date!); // Parsing the date using the correct format
        } catch (e) {
          continue; // If parsing fails, skip this transaction
        }
        String dayKey = '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}'; // Formulating the key as dd-MM

        // Ensure the map for each day is initialized properly
        dailyData.putIfAbsent(dayKey, () => {'Incoming': 0.0, 'Outgoing': 0.0});

        // Using null-safe ways to add amounts
        double amount = transaction.amount ?? 0.0;
        double currentIncoming = dailyData[dayKey]!['Incoming'] ?? 0.0; // Ensure null safety
        double currentOutgoing = dailyData[dayKey]!['Outgoing'] ?? 0.0; // Ensure null safety

        if (transaction.direction == 'Incoming') {
          dailyData[dayKey]!['Incoming'] = currentIncoming + amount;
        } else if (transaction.direction == 'Outgoing') {
          dailyData[dayKey]!['Outgoing'] = currentOutgoing + amount;
        }
      }
    }
    return dailyData;
  }
}




class AppUser {
  final String email;
  final int id;
  final String docId;
  final String pfp;
  final String username;

  AppUser({
    required this.email,
    required this.id,
    required this.docId,
    required this.pfp,
    required this.username,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      email: map['email'],
      id: map['id'],
      docId: map['docId'],
      pfp: map['pfp'],
      username: map['username'],
    );
  }

  Future<void> updatePfp(String pfp) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await FirebaseFirestore.instance.doc("users/$docId").update({"pfp": pfp});
    await prefs.setString("pfp", pfp);
  }

  Future<void> updateUsername(String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await FirebaseFirestore.instance
        .doc("users/$docId")
        .update({"username": username});
    await prefs.setString("username", username);
  }

  Future<Map<String, dynamic>> getUserFavorites() async {
    QuerySnapshot userFavorites = await FirebaseFirestore.instance
        .collection("users/$docId/favorites")
        .get();

    Map<String, dynamic> favoritesMap = {};
    for (var doc in userFavorites.docs) {
      favoritesMap[doc.id] = doc.data();
    }

    return favoritesMap;
  }

  Future<void> saveUserFavorites(
      Map<String, dynamic> transactionDetails) async {
    await FirebaseFirestore.instance
        .collection("users/$docId/favorites")
        .doc(transactionDetails["TransactionID"].toString())
        .set(transactionDetails);
  }

  Future<void> deleteUserFavorites(String transcationId) async {
    await FirebaseFirestore.instance
        .collection("users/$docId/favorites")
        .doc(transcationId)
        .delete();
  }
}

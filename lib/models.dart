import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Transaction {
  final int? userId;
  final int? transactionId;
  final String? type;
  final double? amount;
  final String? status;
  final String? date;
  final String? direction;

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
    return Transaction(
      userId: json['UserID'] as int?,
      transactionId: json['TransactionID'] as int?,
      type: json['TransactionType'] as String?,
      amount: json['Amount'] as double?,
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
    return userId != null && transactionId != null && type != null && amount != null && status != null && date != null && direction != null;
  }

  static Future<List<Transaction>> fetchTransactions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachedData = prefs.getString('transactions');

    List<Transaction> transactions = [];

    if (cachedData != null) {
      Iterable l = json.decode(cachedData);
      transactions = List<Transaction>.from(l.map((model) => Transaction.fromJson(model)));
    } else {
      final response = await http.get(Uri.parse('https://my.api.mockaroo.com/account.json?key=fbb1c1a0'));
      if (response.statusCode == 200) {
        await prefs.setString('transactions', response.body);
        Iterable l = json.decode(response.body);
        transactions = List<Transaction>.from(l.map((model) => Transaction.fromJson(model)));
      } else {
        throw Exception('Failed to load transactions from API');
      }
    }

    // Validate each transaction and filter out invalid ones
    return transactions.where((transaction) => transaction.isValid()).toList();
  }
}

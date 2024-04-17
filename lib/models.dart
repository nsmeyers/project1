import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    double? amount = (json['Amount'] as num?)?.toDouble();
    String? direction = json['Direction'] as String?;
    if (direction == "Outgoing") {
      amount = amount != null ? -amount : null;
    }

    return Transaction(
      userId: json['UserID'] as int?,
      transactionId: json['TransactionID'] as int?,
      type: json['TransactionType'] as String?,
      amount: amount,
      status: json['Status'] as String?,
      date: json['Date'] as String?,
      direction: direction,
    );
  }

  bool isValid() {
    return userId != null ||
        transactionId != null ||
        amount != null ||
        direction != null ||
        date != null;
  }
}

class AppUser {
  final String email;
  final int id;
  final String? pfp;
  final String uid;
  final String username;

  AppUser({
    required this.email,
    required this.id,
    required this.pfp,
    required this.uid,
    required this.username,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      email: map['email'],
      id: map['id'],
      pfp: map['pfp'],
      uid: map['uid'],
      username: map['username'],
    );
  }

  Future<void> updatePfp(String pfp) async {
    String userUid = FirebaseAuth.instance.currentUser!.uid;
    QuerySnapshot userDocs = await FirebaseFirestore.instance
        .collection("users")
        .where("uid", isEqualTo: userUid)
        .get();
    String userDocId = userDocs.docs[0].id;
    await FirebaseFirestore.instance
        .doc("users/$userDocId")
        .update({"pfp": pfp});
  }

  Future<void> updateUsername(String username) async {
    String userUid = FirebaseAuth.instance.currentUser!.uid;
    QuerySnapshot userDocs = await FirebaseFirestore.instance
        .collection("users")
        .where("uid", isEqualTo: userUid)
        .get();
    String userDocId = userDocs.docs[0].id;
    await FirebaseFirestore.instance
        .doc("users/$userDocId")
        .update({"username": username});
  }
}

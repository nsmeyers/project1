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
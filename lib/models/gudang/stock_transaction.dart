import 'package:cloud_firestore/cloud_firestore.dart';

class StockTransaction {
  final String? id;
  final String itemId;
  final String itemName;
  final int quantity;
  final String transactionType; // 'in' for stock in, 'out' for stock out
  final DateTime date;
  final String? notes;
  final String userId;
  final String userName;

  StockTransaction({
    this.id,
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.transactionType,
    required this.date,
    this.notes,
    required this.userId,
    required this.userName,
  });

  factory StockTransaction.fromMap(Map<String, dynamic> map, String docId) {
    return StockTransaction(
      id: docId,
      itemId: map['itemId'] ?? '',
      itemName: map['itemName'] ?? '',
      quantity: map['quantity'] ?? 0,
      transactionType: map['transactionType'] ?? 'in',
      date: (map['date'] as Timestamp).toDate(),
      notes: map['notes'],
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'itemName': itemName,
      'quantity': quantity,
      'transactionType': transactionType,
      'date': date,
      'notes': notes,
      'userId': userId,
      'userName': userName,
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class SalesTransaction {
  final String? id;
  final String cashierId;
  final String cashierName;
  final List<SalesItem> items;
  final double totalAmount;
  final double paidAmount;
  final double changeAmount;
  final String paymentMethod;
  final DateTime date;
  final String? receiptNumber;

  SalesTransaction({
    this.id,
    required this.cashierId,
    required this.cashierName,
    required this.items,
    required this.totalAmount,
    required this.paidAmount,
    required this.changeAmount,
    required this.paymentMethod,
    required this.date,
    this.receiptNumber,
  });

  factory SalesTransaction.fromMap(Map<String, dynamic> map, String docId) {
    return SalesTransaction(
      id: docId,
      cashierId: map['cashierId'] ?? '',
      cashierName: map['cashierName'] ?? '',
      items: (map['items'] as List<dynamic>?)
          ?.map((item) => SalesItem.fromMap(item as Map<String, dynamic>))
          .toList() ?? [],
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      paidAmount: (map['paidAmount'] ?? 0).toDouble(),
      changeAmount: (map['changeAmount'] ?? 0).toDouble(),
      paymentMethod: map['paymentMethod'] ?? 'cash',
      date: (map['date'] as Timestamp).toDate(),
      receiptNumber: map['receiptNumber'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cashierId': cashierId,
      'cashierName': cashierName,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'changeAmount': changeAmount,
      'paymentMethod': paymentMethod,
      'date': date,
      'receiptNumber': receiptNumber,
    };
  }
}

class SalesItem {
  final String itemId;
  final String itemName;
  final int quantity;
  final double price;
  final double subtotal;

  SalesItem({
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.price,
    required this.subtotal,
  });

  factory SalesItem.fromMap(Map<String, dynamic> map) {
    return SalesItem(
      itemId: map['itemId'] ?? '',
      itemName: map['itemName'] ?? '',
      quantity: map['quantity'] ?? 0,
      price: (map['price'] ?? 0).toDouble(),
      subtotal: (map['subtotal'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'itemName': itemName,
      'quantity': quantity,
      'price': price,
      'subtotal': subtotal,
    };
  }
}

enum PaymentMethod {
  cash('Tunai'),
  card('Kartu'),
  transfer('Transfer'),
  ewallet('E-Wallet');

  const PaymentMethod(this.displayName);
  final String displayName;
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../models/gudang/stock_transaction.dart';
import '../widgets/common_widgets.dart';

class StockHistoryPage extends StatelessWidget {
  final String? itemId;

  const StockHistoryPage({Key? key, this.itemId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: 'Riwayat Stok',
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: itemId != null
            ? FirebaseFirestore.instance
                .collection('stock_transactions')
                .where('itemId', isEqualTo: itemId)
                .orderBy('date', descending: true)
                .snapshots()
            : FirebaseFirestore.instance
                .collection('stock_transactions')
                .orderBy('date', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final transactions = snapshot.data!.docs;

          if (transactions.isEmpty) {
            return Center(child: Text('Tidak ada riwayat transaksi'));
          }

          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = StockTransaction.fromMap(
                transactions[index].data() as Map<String, dynamic>,
                transactions[index].id,
              );

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: transaction.transactionType == 'in'
                        ? Colors.green[100]
                        : Colors.red[100],
                    child: Icon(
                      transaction.transactionType == 'in'
                          ? Icons.arrow_downward
                          : Icons.arrow_upward,
                      color: transaction.transactionType == 'in'
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                  title: Text(
                    '${transaction.quantity.abs()} ${transaction.itemName}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: transaction.transactionType == 'in'
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(transaction.notes ?? '-'),
                      Text(
                        'Oleh: ${transaction.userName}',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(transaction.date),
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

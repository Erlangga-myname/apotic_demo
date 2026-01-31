import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import '../usersAndItemsModel.dart';
import '../services/firebase_service.dart';

class FinancialReportsPage extends StatefulWidget {
  @override
  _FinancialReportsPageState createState() => _FinancialReportsPageState();
}

class _FinancialReportsPageState extends State<FinancialReportsPage> {
  final FirebaseService _firebaseService = FirebaseService();
  List<TransactionModel>? _transactions;
  int _totalIncome = 0;
  int _totalExpense = 0;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() async {
    try {
      List<TransactionModel> txs = await _firebaseService.getTransactions();
      int income = 0;
      int expense = 0;
      for (var tx in txs) {
        if (tx.type == 'income') {
          income += tx.amount;
        } else {
          expense += tx.amount;
        }
      }
      setState(() {
        _transactions = txs;
        _totalIncome = income;
        _totalExpense = expense;
      });
    } catch (e) {
      print("Error loading transactions: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    Color brandDark = HexColor("147158");
    final currencyFormat = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: Color(0xFFF5F7F8),
      appBar: AppBar(
        title: Text(
          'Laporan Keuangan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: brandDark,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildSummaryHeader(brandDark, currencyFormat),
          Expanded(
            child: _transactions == null
                ? Center(child: CircularProgressIndicator(color: brandDark))
                : _transactions!.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.all(24),
                    itemCount: _transactions!.length,
                    itemBuilder: (context, index) => _buildTransactionCard(
                      _transactions![index],
                      currencyFormat,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader(Color brandDark, NumberFormat format) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, 0, 24, 32),
      decoration: BoxDecoration(
        color: brandDark,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem(
                "Pemasukan",
                _totalIncome,
                Colors.greenAccent,
                format,
              ),
              _buildSummaryItem(
                "Pengeluaran",
                _totalExpense,
                Colors.orangeAccent,
                format,
              ),
            ],
          ),
          SizedBox(height: 24),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Saldo Bersih", style: TextStyle(color: Colors.white70)),
                Text(
                  format.format(_totalIncome - _totalExpense),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    int amount,
    Color color,
    NumberFormat format,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 12)),
        Text(
          format.format(amount),
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 64, color: Colors.grey.shade300),
          SizedBox(height: 16),
          Text("Belum ada transaksi.", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(TransactionModel tx, NumberFormat format) {
    bool isIncome = tx.type == 'income';
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: (isIncome ? Colors.green : Colors.red).withOpacity(
            0.1,
          ),
          child: Icon(
            isIncome ? Icons.arrow_downward : Icons.arrow_upward,
            color: isIncome ? Colors.green : Colors.red,
            size: 20,
          ),
        ),
        title: Text(tx.title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          DateFormat('dd MMM yyyy, HH:mm').format(tx.date),
          style: TextStyle(fontSize: 11),
        ),
        trailing: Text(
          (isIncome ? "+ " : "- ") + format.format(tx.amount),
          style: TextStyle(
            color: isIncome ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

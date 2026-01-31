import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:hexcolor/hexcolor.dart';

import '../services/firebase_service.dart';
import '../usersAndItemsModel.dart';
import '../widgets/common_widgets.dart';
import 'stock_transaction_page.dart';

class LowStockPage extends StatefulWidget {
  @override
  _LowStockPageState createState() => _LowStockPageState();
}

class _LowStockPageState extends State<LowStockPage> {
  List<Item>? items;
  final NumberFormat numberFormat = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  Future<void> _refreshItems() async {
    try {
      List<Item> updatedItems = await FirebaseService().getItems();
      if (mounted) {
        setState(() => items = updatedItems);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _refreshItems();
  }

  @override
  Widget build(BuildContext context) {
    Color brandDark = HexColor("147158");
    Color brandLight = HexColor("6AB29B");

    return Scaffold(
      backgroundColor: Color(0xFFF5F7F8),
      appBar: CommonAppBar(
        title: 'Stok Menipis',
        showBackButton: true,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
                    SizedBox(width: 12),
                    Text(
                      "Peringatan Stok",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  items == null
                      ? "Memproses..."
                      : "${items!.where((item) => item.quantity < 10).length} item perlu restock",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: items == null
                ? Center(child: CircularProgressIndicator(color: brandDark))
                : RefreshIndicator(
                    onRefresh: _refreshItems,
                    color: brandDark,
                    child: items!.isEmpty
                        ? _buildEmptyState()
                        : _buildLowStockList(brandDark, brandLight),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 64, color: Colors.green.shade300),
          SizedBox(height: 16),
          Text(
            "Semua stok aman!",
            style: TextStyle(color: Colors.grey, fontSize: 18),
          ),
          SizedBox(height: 8),
          Text(
            "Tidak ada item dengan stok menipis",
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildLowStockList(Color brandDark, Color brandLight) {
    final lowStockItems = items!.where((item) => item.quantity < 10).toList();

    if (lowStockItems.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: lowStockItems.length,
      itemBuilder: (context, index) {
        final item = lowStockItems[index];
        bool criticalStock = item.quantity < 5;

        return Container(
          margin: EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: criticalStock ? Colors.red.shade200 : Colors.orange.shade200,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Image
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: item.imagePath != null && item.imagePath!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(item.imagePath!),
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => Icon(
                                  Icons.medication,
                                  color: Colors.grey.shade400,
                                  size: 32,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.medication,
                              color: Colors.grey.shade400,
                              size: 32,
                            ),
                    ),
                    SizedBox(width: 16),
                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: criticalStock
                                      ? Colors.red.withOpacity(0.1)
                                      : Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  criticalStock ? "KRITIS" : "MENIPIS",
                                  style: TextStyle(
                                    color: criticalStock ? Colors.red : Colors.orange,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            item.type,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                numberFormat.format(item.price),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: brandDark,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.inventory_2,
                                    size: 14,
                                    color: criticalStock ? Colors.red : Colors.orange,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    "Stok: ${item.quantity}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: criticalStock ? Colors.red : Colors.orange,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Quick Action Button
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Perlu restock segera?",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StockTransactionPage(item: item),
                          ),
                        ).then((_) => _refreshItems());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandDark,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: Icon(Icons.add, color: Colors.white, size: 16),
                      label: Text(
                        "RESTOCK",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


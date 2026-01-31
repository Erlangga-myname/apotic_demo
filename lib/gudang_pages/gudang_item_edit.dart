import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:hexcolor/hexcolor.dart';

import '../services/firebase_service.dart';
import '../usersAndItemsModel.dart';
import '../widgets/common_widgets.dart';
import 'stock_transaction_page.dart';
import 'stock_history_page.dart';

class GudangItemDetailPage extends StatefulWidget {
  final Item item;

  const GudangItemDetailPage({Key? key, required this.item}) : super(key: key);

  @override
  _GudangItemDetailPageState createState() => _GudangItemDetailPageState();
}

class _GudangItemDetailPageState extends State<GudangItemDetailPage> {
  late Item _item;
  final NumberFormat numberFormat = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
  }

  Future<void> _updateQuantity(int adjustment) async {
    setState(() => _isLoading = true);
    try {
      final newQuantity = _item.quantity + adjustment;
      await FirebaseFirestore.instance
          .collection('items')
          .doc(_item.docId)
          .update({'quantity': newQuantity});

      setState(() {
        _item = Item(
          id: _item.id,
          name: _item.name,
          type: _item.type,
          description: _item.description,
          price: _item.price,
          quantity: newQuantity,
          imagePath: _item.imagePath,
          docId: _item.docId,
        );
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              adjustment > 0
                  ? 'Stok berhasil ditambahkan'
                  : 'Stok berhasil dikurangi',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengupdate stok: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteItem() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Hapus Item'),
        content: Text('Apakah Anda yakin ingin menghapus "${_item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await FirebaseService().deleteItem(_item.docId!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Item berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus item: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Color brandDark = HexColor("147158");
    Color brandLight = HexColor("6AB29B");
    bool lowStock = _item.quantity < 10;
    bool criticalStock = _item.quantity < 5;

    return Scaffold(
      backgroundColor: Color(0xFFF5F7F8),
      appBar: CommonAppBar(
        title: 'Detail Item',
        showBackButton: true,
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _isLoading ? null : _deleteItem,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: brandDark))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header with image
                  Container(
                    margin: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Image
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: _item.imagePath != null &&
                                  _item.imagePath!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: Image.file(
                                    File(_item.imagePath!),
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => Icon(
                                      Icons.medication,
                                      color: Colors.grey.shade400,
                                      size: 80,
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.medication,
                                  color: Colors.grey.shade400,
                                  size: 80,
                                ),
                        ),
                        // Item Info
                        Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: brandLight.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _item.type,
                                      style: TextStyle(
                                        color: brandDark,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Spacer(),
                                  if (lowStock)
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: (criticalStock
                                                ? Colors.red
                                                : Colors.orange)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.warning_amber_rounded,
                                            color: criticalStock
                                                ? Colors.red
                                                : Colors.orange,
                                            size: 16,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            criticalStock ? "KRITIS" : "MENIPIS",
                                            style: TextStyle(
                                              color: criticalStock
                                                  ? Colors.red
                                                  : Colors.orange,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Text(
                                _item.name,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                _item.description,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Harga Jual",
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        numberFormat.format(_item.price),
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: brandDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "Stok Tersedia",
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            "${_item.quantity}",
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: lowStock
                                                  ? Colors.red
                                                  : brandDark,
                                            ),
                                          ),
                                          Text(
                                            " unit",
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
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

                  // Quick Actions
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      "Aksi Cepat",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildActionCard(
                            context,
                            icon: Icons.add_circle_outline,
                            label: "Tambah Stok",
                            color: Colors.green,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    StockTransactionPage(item: _item),
                              ),
                            ).then((_) {
                              // Refresh item data
                              FirebaseService()
                                  .getItems()
                                  .then((items) {
                                final updated = items.firstWhere(
                                  (i) => i.docId == _item.docId,
                                );
                                if (mounted) {
                                  setState(() => _item = updated);
                                }
                              });
                            }),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildActionCard(
                            context,
                            icon: Icons.remove_circle_outline,
                            label: "Kurangi Stok",
                            color: Colors.orange,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    StockTransactionPage(item: _item),
                              ),
                            ).then((_) {
                              // Refresh item data
                              FirebaseService()
                                  .getItems()
                                  .then((items) {
                                final updated = items.firstWhere(
                                  (i) => i.docId == _item.docId,
                                );
                                if (mounted) {
                                  setState(() => _item = updated);
                                }
                              });
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildActionCard(
                            context,
                            icon: Icons.history,
                            label: "Riwayat",
                            color: brandDark,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    StockHistoryPage(itemId: _item.docId),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildActionCard(
                            context,
                            icon: Icons.qr_code,
                            label: "QR Code",
                            color: Colors.blue,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Fitur QR Code coming soon')),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}


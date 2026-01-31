import 'package:flutter/material.dart';
import 'dart:io';
import '../usersAndItemsModel.dart';
import '../services/firebase_service.dart';
import 'package:intl/intl.dart';
import 'package:hexcolor/hexcolor.dart';

class DeleteItemPage extends StatefulWidget {
  @override
  _DeleteItemPageState createState() => _DeleteItemPageState();
}

class _DeleteItemPageState extends State<DeleteItemPage> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Item>? items;
  List<bool>? selectedItems;
  final NumberFormat numberFormat = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _refreshItems();
  }

  Future<void> _refreshItems() async {
    try {
      List<Item> updatedItems = await _firebaseService.getItems();
      setState(() {
        items = updatedItems;
        selectedItems = List<bool>.generate(
          updatedItems.length,
          (index) => false,
        );
      });
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat data.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    Color brandDark = HexColor("147158");
    int selectedCount = selectedItems?.where((e) => e).length ?? 0;

    return Scaffold(
      backgroundColor: Color(0xFFF5F7F8),
      appBar: AppBar(
        title: Text(
          'Hapus Produk',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: brandDark,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          if (selectedCount > 0)
            IconButton(
              icon: Icon(Icons.delete_sweep, color: Colors.white),
              onPressed: () => _showDeleteConfirmation(context),
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(24, 8, 24, 24),
            decoration: BoxDecoration(
              color: brandDark,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Mode Penghapusan",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                SizedBox(height: 8),
                Text(
                  selectedCount == 0
                      ? "Pilih Produk"
                      : "$selectedCount Dipilih",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshItems,
              color: brandDark,
              child: items == null
                  ? Center(child: CircularProgressIndicator(color: brandDark))
                  : items!.isEmpty
                  ? Center(child: Text("Belum ada data obat."))
                  : ListView.builder(
                      padding: EdgeInsets.all(24),
                      itemCount: items!.length,
                      itemBuilder: (context, index) =>
                          _buildDeleteCard(index, items![index], brandDark),
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: selectedCount > 0
          ? FloatingActionButton.extended(
              onPressed: () => _showDeleteConfirmation(context),
              backgroundColor: Colors.redAccent,
              icon: Icon(Icons.delete, color: Colors.white),
              label: Text(
                "HAPUS SEKARANG",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildDeleteCard(int index, Item item, Color brandDark) {
    bool isSelected = selectedItems?[index] ?? false;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedItems?[index] = !isSelected;
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.redAccent : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: EdgeInsets.all(12),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.redAccent.withOpacity(0.1)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: isSelected
                  ? Icon(Icons.check_circle, color: Colors.redAccent)
                  : item.imagePath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(item.imagePath!),
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(Icons.medication_outlined, color: Colors.grey),
            ),
          ),
          title: Text(
            item.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.redAccent : Colors.black87,
            ),
          ),
          subtitle: Text(
            "${item.type} • Stok: ${item.quantity}",
            style: TextStyle(fontSize: 12),
          ),
          trailing: Checkbox(
            activeColor: Colors.redAccent,
            shape: CircleBorder(),
            value: isSelected,
            onChanged: (val) {
              setState(() {
                selectedItems?[index] = val ?? false;
              });
            },
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    int count = selectedItems?.where((e) => e).length ?? 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Text("Konfirmasi Hapus"),
          ],
        ),
        content: Text(
          "Apakah Anda yakin ingin menghapus $count produk terpilih? Tindakan ini tidak dapat dibatalkan.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("BATAL", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteSelectedItems();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "YA, HAPUS",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSelectedItems() async {
    try {
      List<String> toDelete = [];
      for (int i = 0; i < selectedItems!.length; i++) {
        if (selectedItems![i]) toDelete.add(items![i].docId!);
      }

      for (String docId in toDelete) {
        await _firebaseService.deleteItem(docId);
      }

      await _refreshItems();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Produk berhasil dihapus.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan saat menghapus.')),
      );
    }
  }
}

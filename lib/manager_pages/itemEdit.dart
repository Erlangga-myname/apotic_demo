import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:hexcolor/hexcolor.dart';
import '../usersAndItemsModel.dart';
import '../services/firebase_service.dart';

class EditItemPage extends StatefulWidget {
  @override
  _EditItemPageState createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Item>? items;
  final NumberFormat numberFormat = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  Future<void> _refreshItems() async {
    try {
      List<Item> updatedItems = await _firebaseService.getItems();
      setState(() => items = updatedItems);
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat data.')));
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

    return Scaffold(
      backgroundColor: Color(0xFFF5F7F8),
      appBar: AppBar(
        title: Text(
          'Edit Data Obat',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: brandDark,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
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
            child: Text(
              "Pilih obat dari daftar di bawah ini untuk memperbarui informasi detailnya.",
              style: TextStyle(color: Colors.white70, fontSize: 14),
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
                          _buildSelectionCard(items![index], brandDark),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionCard(Item item, Color brandDark) {
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
        contentPadding: EdgeInsets.all(12),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: item.imagePath != null
                ? Image.file(File(item.imagePath!), fit: BoxFit.cover)
                : Icon(Icons.medication_outlined, color: Colors.grey),
          ),
        ),
        title: Text(
          item.name,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        subtitle: Text(
          "${item.type} • ${numberFormat.format(item.price)}",
          style: TextStyle(fontSize: 12),
        ),
        trailing: Icon(Icons.edit_outlined, color: brandDark),
        onTap: () => _showEditModal(context, item),
      ),
    );
  }

  void _showEditModal(BuildContext context, Item item) {
    final TextEditingController nameController = TextEditingController(
      text: item.name,
    );
    final TextEditingController quantityController = TextEditingController(
      text: item.quantity.toString(),
    );
    final TextEditingController priceController = TextEditingController(
      text: item.price.toString(),
    );
    final TextEditingController descController = TextEditingController(
      text: item.description,
    );
    String currentType = item.type;
    Color brandDark = HexColor("147158");

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'Update Detail Produk',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: brandDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                _buildModalField(
                  label: 'Nama Obat',
                  icon: Icons.medication,
                  controller: nameController,
                  brandColor: brandDark,
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildModalField(
                        label: 'Harga',
                        icon: Icons.payments,
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        brandColor: brandDark,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildModalField(
                        label: 'Stok',
                        icon: Icons.inventory,
                        controller: quantityController,
                        keyboardType: TextInputType.number,
                        brandColor: brandDark,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                _buildModalField(
                  label: 'Deskripsi',
                  icon: Icons.description,
                  controller: descController,
                  maxLines: 2,
                  brandColor: brandDark,
                ),
                SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () async {
                    Item updatedItem = Item(
                      id: item.id,
                      name: nameController.text,
                      type: currentType,
                      description: descController.text,
                      quantity:
                          int.tryParse(quantityController.text) ??
                          item.quantity,
                      price: int.tryParse(priceController.text) ?? item.price,
                      imagePath: item.imagePath,
                      docId: item.docId,
                    );

                    try {
                      await _firebaseService.updateItem(updatedItem);
                      Navigator.pop(context);
                      _refreshItems();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Data berhasil diperbarui.')),
                      );
                    } catch (error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal memperbarui data.')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandDark,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'SIMPAN PERUBAHAN',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModalField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required Color brandColor,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: brandColor, size: 20),
        filled: true,
        fillColor: Colors.grey.shade50,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: brandColor),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:hexcolor/hexcolor.dart';

import '../providers/user_provider.dart';
import '../models/shared/user_models.dart';
import '../usersAndItemsModel.dart';
import '../models/gudang/stock_transaction.dart';
import '../services/firebase_service.dart';
import '../widgets/common_widgets.dart';

class StockTransactionPage extends StatefulWidget {
  final Item? item;

  const StockTransactionPage({Key? key, this.item}) : super(key: key);

  @override
  _StockTransactionPageState createState() => _StockTransactionPageState();
}

class _StockTransactionPageState extends State<StockTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  String _transactionType = 'in';
  bool _isLoading = false;
  Item? _selectedItem;
  final _firestore = FirebaseFirestore.instance;
  final NumberFormat numberFormat = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.item;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectItem() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: ItemSelectionSheet(
          onItemSelected: (item) {
            setState(() {
              _selectedItem = item;
            });
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedItem == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pilih item terlebih dahulu')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userData = Provider.of<UserData>(context, listen: false);
      final user = userData.loggedInUser as User;

      final quantity = int.parse(_quantityController.text);

      // Calculate new quantity
      final currentQuantity = _selectedItem!.quantity;
      final newQuantity = _transactionType == 'in'
          ? currentQuantity + quantity
          : currentQuantity - quantity;

      // Create transaction
      final transaction = StockTransaction(
        itemId: _selectedItem!.docId.toString(),
        itemName: _selectedItem!.name,
        quantity: _transactionType == 'in' ? quantity : -quantity,
        transactionType: _transactionType,
        date: DateTime.now(),
        notes: _notesController.text,
        userId: user.id.toString(),
        userName: user.username,
      );

      // Save transaction to Firestore
      await _firestore.collection('stock_transactions').add(transaction.toMap());

      // Update item quantity in Firestore
      await _firestore.collection('items').doc(_selectedItem!.docId).update({
        'quantity': newQuantity,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transaksi berhasil! Stok ${_selectedItem!.name} ${_transactionType == 'in' ? 'ditambah' : 'dikurangi'} $quantity'),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan transaksi: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Color brandDark = HexColor("147158");
    Color brandLight = HexColor("6AB29B");

    return Scaffold(
      backgroundColor: Color(0xFFF5F7F8),
      appBar: CommonAppBar(
        title: 'Transaksi Stok',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Item Selection
              SectionTitle(title: "Pilih Item"),
              SizedBox(height: 12),
              GestureDetector(
                onTap: _selectItem,
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _selectedItem == null ? Colors.grey.shade300 : brandDark,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _selectedItem == null
                      ? Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: brandLight.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.add, color: brandDark),
                            ),
                            SizedBox(width: 16),
                            Text(
                              "Ketuk untuk memilih item",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            // Item Image
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: _selectedItem!.imagePath != null &&
                                      _selectedItem!.imagePath!.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        File(_selectedItem!.imagePath!),
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) => Icon(
                                          Icons.medication,
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      Icons.medication,
                                      color: Colors.grey.shade400,
                                    ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedItem!.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: brandLight.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _selectedItem!.type,
                                      style: TextStyle(
                                        color: brandDark,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        numberFormat.format(_selectedItem!.price),
                                        style: TextStyle(
                                          color: brandDark,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        "Stok: ${_selectedItem!.quantity}",
                                        style: TextStyle(
                                          color: _selectedItem!.quantity < 10
                                              ? Colors.red
                                              : Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.grey.shade400,
                              size: 16,
                            ),
                          ],
                        ),
                ),
              ),
              SizedBox(height: 24),

              // Transaction Type
              SectionTitle(title: "Tipe Transaksi"),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _transactionType = 'in'),
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _transactionType == 'in'
                              ? brandDark
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _transactionType == 'in'
                                ? brandDark
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              color: _transactionType == 'in'
                                  ? Colors.white
                                  : Colors.grey.shade600,
                              size: 32,
                            ),
                            SizedBox(height: 8),
                            Text(
                              "STOK MASUK",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _transactionType == 'in'
                                    ? Colors.white
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _transactionType = 'out'),
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _transactionType == 'out'
                              ? Colors.red
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _transactionType == 'out'
                                ? Colors.red
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.remove_circle_outline,
                              color: _transactionType == 'out'
                                  ? Colors.white
                                  : Colors.grey.shade600,
                              size: 32,
                            ),
                            SizedBox(height: 8),
                            Text(
                              "STOK KELUAR",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _transactionType == 'out'
                                    ? Colors.white
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),

              // Quantity
              SectionTitle(
                title: _transactionType == 'in'
                    ? "Jumlah Masuk"
                    : "Jumlah Keluar",
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                style: TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Masukkan jumlah',
                  prefixIcon:
                      Icon(Icons.numbers, color: brandDark),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: brandDark, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah tidak boleh kosong';
                  }
                  final qty = int.tryParse(value);
                  if (qty == null || qty <= 0) {
                    return 'Jumlah harus lebih dari 0';
                  }
                  if (_transactionType == 'out' &&
                      _selectedItem != null &&
                      qty > _selectedItem!.quantity) {
                    return 'Stok tidak mencukupi (max: ${_selectedItem!.quantity})';
                  }
                  return null;
                },
              ),
              if (_transactionType == 'out' &&
                  _selectedItem != null &&
                  int.tryParse(_quantityController.text) != null &&
                  int.parse(_quantityController.text) <=
                      _selectedItem!.quantity)
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 8),
                  child: Text(
                    "Sisa stok akan menjadi: ${_selectedItem!.quantity - int.parse(_quantityController.text)}",
                    style: TextStyle(
                      color: brandDark,
                      fontSize: 12,
                    ),
                  ),
                ),
              SizedBox(height: 24),

              // Notes
              SectionTitle(title: "Keterangan (Opsional)"),
              SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                style: TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Tambahkan catatan...',
                  prefixIcon: Icon(Icons.note, color: brandDark),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: brandDark, width: 2),
                  ),
                ),
              ),
              SizedBox(height: 32),

              // Save Button
              ElevatedButton(
                onPressed: _isLoading ? null : _saveTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandDark,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                child: _isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _transactionType == 'in'
                                ? Icons.add
                                : Icons.remove,
                            color: Colors.white,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'SIMPAN TRANSAKSI',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Item Selection Bottom Sheet
class ItemSelectionSheet extends StatefulWidget {
  final Function(Item) onItemSelected;

  const ItemSelectionSheet({Key? key, required this.onItemSelected})
      : super(key: key);

  @override
  _ItemSelectionSheetState createState() => _ItemSelectionSheetState();
}

class _ItemSelectionSheetState extends State<ItemSelectionSheet> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final NumberFormat numberFormat = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color brandDark = HexColor("147158");

    return Column(
      children: [
        // Handle bar
        Container(
          margin: EdgeInsets.only(top: 12),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Text(
                "Pilih Item",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: Colors.grey),
              ),
            ],
          ),
        ),
        // Search field
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
            decoration: InputDecoration(
              hintText: 'Cari item...',
              prefixIcon: Icon(Icons.search, color: brandDark),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        SizedBox(height: 16),
        // Items list
        Expanded(
          child: FutureBuilder<List<Item>>(
            future: FirebaseService().getItems(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(color: brandDark));
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red),
                      SizedBox(height: 16),
                      Text('Error: ${snapshot.error}'),
                    ],
                  ),
                );
              }

              final items = snapshot.data ?? [];
              final filteredItems = _searchQuery.isEmpty
                  ? items
                  : items
                      .where((item) =>
                          item.name.toLowerCase().contains(_searchQuery) ||
                          item.type.toLowerCase().contains(_searchQuery))
                      .toList();

              if (filteredItems.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined,
                          size: 48, color: Colors.grey.shade300),
                      SizedBox(height: 16),
                      Text(
                        _searchQuery.isEmpty
                            ? "Belum ada item"
                            : "Item tidak ditemukan",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 24),
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  bool lowStock = item.quantity < 10;

                  return GestureDetector(
                    onTap: () => widget.onItemSelected(item),
                    child: Container(
                      margin: EdgeInsets.only(bottom: 12),
                      padding: EdgeInsets.all(12),
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
                      child: Row(
                        children: [
                          // Image
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: item.imagePath != null &&
                                    item.imagePath!.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      File(item.imagePath!),
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, e, s) => Icon(
                                        Icons.medication,
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                  )
                                : Icon(
                                    Icons.medication,
                                    color: Colors.grey.shade400,
                                  ),
                          ),
                          SizedBox(width: 12),
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
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (lowStock)
                                      Icon(
                                        Icons.warning_amber_rounded,
                                        color: Colors.orange,
                                        size: 16,
                                      ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.brandLight.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item.type,
                                    style: TextStyle(
                                      color: AppColors.brandDark,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      numberFormat.format(item.price),
                                      style: TextStyle(
                                        color: AppColors.brandDark,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Stok: ${item.quantity}",
                                      style: TextStyle(
                                        color: lowStock
                                            ? Colors.red
                                            : Colors.green.shade700,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey.shade400,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import '../usersAndItemsModel.dart';
import '../services/firebase_service.dart';
import '../providers/user_provider.dart';
import '../models/shared/user_models.dart';
import '../login/login.dart';
import '../widgets/common_widgets.dart';
import '../models/kasir/sales_transaction.dart';
import 'sales_history_page.dart';
import 'payment_dialog.dart';

class KasirHomePage extends StatefulWidget {
  @override
  _KasirHomePageState createState() => _KasirHomePageState();
}

class _KasirHomePageState extends State<KasirHomePage> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Item>? _items;
  List<Item>? _filteredItems;
  List<CartItem> _cart = [];
  final TextEditingController _searchController = TextEditingController();
  
  // Format Rupiah Indonesia yang benar
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    List<Item> items = await _firebaseService.getItems();
    if (mounted) {
      setState(() {
        _items = items;
        _filteredItems = items;
      });
    }
  }

  void _filterItems(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _applyFilters();
    });
  }

  void _applyFilters() {
    if (_searchQuery.isEmpty && _selectedCategory == 'Semua') {
      _filteredItems = _items;
    } else {
      _filteredItems = _items!.where((item) {
        final matchesSearch = _searchQuery.isEmpty ||
            item.name.toLowerCase().contains(_searchQuery) ||
            item.type.toLowerCase().contains(_searchQuery);
        final matchesCategory = _selectedCategory == 'Semua' ||
            item.type == _selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    }
  }

  void _setCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _applyFilters();
    });
  }

  void _addToCart(Item item) {
    if (item.quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stok ${item.name} habis!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      int index = _cart.indexWhere((c) => c.name == item.name);
      if (index != -1) {
        if (_cart[index].quantity < item.quantity) {
          _cart[index].quantity++;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Stok tidak mencukupi')),
          );
        }
      } else {
        _cart.add(
          CartItem(
            name: item.name,
            quantity: 1,
            price: item.price,
            imagePath: item.imagePath,
          ),
        );
      }
    });
  }

  int get _totalPrice =>
      _cart.fold(0, (sum, item) => sum + (item.price * item.quantity));

  int get _totalItems => _cart.fold(0, (sum, item) => sum + item.quantity);

  @override
  Widget build(BuildContext context) {
    Color brandDark = HexColor("147158");
    var userData = Provider.of<UserData>(context, listen: false);

    return Scaffold(
      backgroundColor: Color(0xFFF5F7F8),
      drawer: _buildDrawer(context, brandDark),
      appBar: AppBar(
        title: Text(
          'Kasir Panel',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: brandDark,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SalesHistoryPage()),
            ),
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              userData.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Left Side: Item Grid (65%)
          Expanded(
            flex: 65,
            child: Column(
              children: [
                // Search Bar
                Container(
                  padding: EdgeInsets.all(16),
                  color: Colors.white,
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterItems,
                    decoration: InputDecoration(
                      hintText: 'Cari obat...',
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                // Category Chips
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: Colors.white,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _buildCategoryChips(brandDark),
                    ),
                  ),
                ),
                // Item Grid
                Expanded(
                  child: _items == null
                      ? Center(child: CircularProgressIndicator(color: brandDark))
                      : (_filteredItems!.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
                                  SizedBox(height: 16),
                                  Text("Item tidak ditemukan", style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadItems,
                              color: brandDark,
                              child: GridView.builder(
                                padding: EdgeInsets.all(16),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 0.9,
                                ),
                                itemCount: _filteredItems!.length,
                                itemBuilder: (context, index) =>
                                    _buildItemCard(_filteredItems![index], brandDark),
                              ),
                            )),
                ),
              ],
            ),
          ),
          // Right Side: Cart (35%)
          Container(
            width: 380,
            color: Colors.white,
            child: _buildCartSection(brandDark),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCategoryChips(Color brandDark) {
    final categories = ['Semua', 'Obat', 'Alkes', 'Vitamin', 'Suplemen', 'Lainnya'];
    
    return categories.map((category) {
      final isSelected = _selectedCategory == category;
      return Padding(
        padding: EdgeInsets.only(right: 8),
        child: FilterChip(
          selected: isSelected,
          label: Text(category),
          onSelected: (_) => _setCategory(category),
          selectedColor: brandDark,
          checkmarkColor: Colors.white,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          side: BorderSide(color: isSelected ? brandDark : Colors.grey.shade300),
        ),
      );
    }).toList();
  }

  Widget _buildItemCard(Item item, Color brandDark) {
    bool lowStock = item.quantity < 10;
    bool outOfStock = item.quantity <= 0;

    return GestureDetector(
      onTap: outOfStock ? null : () => _addToCart(item),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: outOfStock
                ? Colors.red.shade200
                : lowStock
                    ? Colors.orange.shade200
                    : Colors.transparent,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: item.imagePath != null && item.imagePath!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        child: Image.file(
                          File(item.imagePath!),
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Icon(
                            Icons.medication,
                            size: 40,
                            color: brandDark.withOpacity(0.3),
                          ),
                        ),
                      )
                    : Icon(
                        Icons.medication,
                        size: 40,
                        color: brandDark.withOpacity(0.3),
                      ),
              ),
            ),
            // Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Spacer(),
                    Text(
                      _currencyFormat.format(item.price),
                      style: TextStyle(
                        color: brandDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          outOfStock
                              ? Icons.remove_circle
                              : lowStock
                                  ? Icons.warning
                                  : Icons.check_circle,
                          size: 12,
                          color: outOfStock
                              ? Colors.red
                              : lowStock
                                  ? Colors.orange
                                  : Colors.green,
                        ),
                        SizedBox(width: 4),
                        Text(
                          outOfStock ? "Habis" : "${item.quantity}",
                          style: TextStyle(
                            fontSize: 11,
                            color: outOfStock
                                ? Colors.red
                                : lowStock
                                    ? Colors.orange
                                    : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartSection(Color brandDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header - Flat design
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: brandDark,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.shopping_cart, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Keranjang",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (_cart.isNotEmpty)
                GestureDetector(
                  onTap: () => setState(() => _cart.clear()),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "Clear",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
        ),
        // Cart Items
        Expanded(
          child: _cart.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 48,
                        color: Colors.grey.shade300,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Keranjang kosong",
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Klik item untuk menambah",
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _cart.length,
                  itemBuilder: (context, index) =>
                      _buildCartItem(_cart[index], index, brandDark),
                ),
        ),
        // Footer - Total & Bayar
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  Text(
                    _currencyFormat.format(_totalPrice),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: brandDark,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _cart.isEmpty ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandDark,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "BAYAR",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCartItem(CartItem item, int index, Color brandDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _currencyFormat.format(item.price),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.remove, size: 18),
                  onPressed: () => setState(() {
                    if (item.quantity > 1) {
                      item.quantity--;
                    } else {
                      _cart.removeAt(index);
                    }
                  }),
                ),
                SizedBox(
                  width: 28,
                  child: Text(
                    "${item.quantity}",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add, size: 18),
                  onPressed: () => setState(() {
                    item.quantity++;
                  }),
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          Text(
            _currencyFormat.format(item.price * item.quantity),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: brandDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, Color brandDark) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: brandDark,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Text(
                  "Apotic",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Kasir Panel",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.receipt_long),
            title: Text("Riwayat Penjualan"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SalesHistoryPage()),
              );
            },
          ),
          Divider(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              "KATEGORI",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.apps),
            title: Text("Semua Item"),
            selected: _selectedCategory == 'Semua',
            selectedTileColor: brandDark.withOpacity(0.1),
            onTap: () {
              _setCategory('Semua');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.medication),
            title: Text("Obat"),
            selected: _selectedCategory == 'Obat',
            selectedTileColor: brandDark.withOpacity(0.1),
            onTap: () {
              _setCategory('Obat');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.medical_services),
            title: Text("Alat Kesehatan"),
            selected: _selectedCategory == 'Alkes',
            selectedTileColor: brandDark.withOpacity(0.1),
            onTap: () {
              _setCategory('Alkes');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.health_and_safety),
            title: Text("Vitamin"),
            selected: _selectedCategory == 'Vitamin',
            selectedTileColor: brandDark.withOpacity(0.1),
            onTap: () {
              _setCategory('Vitamin');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.spa),
            title: Text("Suplemen"),
            selected: _selectedCategory == 'Suplemen',
            selectedTileColor: brandDark.withOpacity(0.1),
            onTap: () {
              _setCategory('Suplemen');
              Navigator.pop(context);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () {
              final userData = Provider.of<UserData>(context, listen: false);
              userData.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _processPayment() async {
    if (_cart.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => PaymentDialog(
        totalAmount: _totalPrice.toDouble(),
        onPaymentComplete: (method, paidAmount) async {
          await _completeTransaction(method, paidAmount.toInt());
        },
      ),
    );
  }

  Future<void> _completeTransaction(PaymentMethod paymentMethod, int paidAmount) async {
    if (_cart.isEmpty) return;

    try {
      final userData = Provider.of<UserData>(context, listen: false);
      final user = userData.loggedInUser as User;

      String receiptNumber =
          'RX${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

      List<SalesItem> salesItems = [];
      for (var cartItem in _cart) {
        Item item = _items!.firstWhere((i) => i.name == cartItem.name);

        await _firebaseService.updateItemQuantity(
          item.docId!,
          item.quantity - cartItem.quantity,
        );

        salesItems.add(
          SalesItem(
            itemId: item.docId!,
            itemName: cartItem.name,
            quantity: cartItem.quantity,
            price: cartItem.price.toDouble(),
            subtotal: (cartItem.price * cartItem.quantity).toDouble(),
          ),
        );
      }

      final transaction = SalesTransaction(
        cashierId: user.uid,
        cashierName: user.namaLengkap,
        items: salesItems,
        totalAmount: _totalPrice.toDouble(),
        paidAmount: paidAmount.toDouble(),
        changeAmount: (paidAmount - _totalPrice).toDouble(),
        paymentMethod: paymentMethod.displayName,
        date: DateTime.now(),
        receiptNumber: receiptNumber,
      );

      await FirebaseFirestore.instance
          .collection('sales_transactions')
          .add(transaction.toMap());

      await _firebaseService.addTransaction(
        TransactionModel(
          type: 'income',
          title: 'Penjualan #$receiptNumber',
          amount: _totalPrice,
          date: DateTime.now(),
          userId: user.uid,
          userName: user.namaLengkap,
        ),
      );

setState(() => _cart.clear());
      _loadItems();

      // Simpan total sebelum cart di-clear
      final totalBeforeClear = _totalPrice;
      _showSuccessDialog(receiptNumber, totalBeforeClear);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal memproses transaksi: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccessDialog(String receiptNumber, int totalAmount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: EdgeInsets.all(24),
        title: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 48),
              SizedBox(height: 12),
              Text(
                "Transaksi Berhasil!",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Divider(),
            _buildDetailRow("No. Struk", receiptNumber),
            SizedBox(height: 8),
            _buildDetailRow("Total", _currencyFormat.format(totalAmount)),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.brandDark.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2, color: AppColors.brandDark, size: 18),
                  SizedBox(width: 8),
                  Text(
                    "Stok telah diperbarui",
                    style: TextStyle(
                      color: AppColors.brandDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SalesHistoryPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandDark,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                "Lihat Riwayat",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14),
                foregroundColor: Colors.black,
              ),
              child: Text("Tutup"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}


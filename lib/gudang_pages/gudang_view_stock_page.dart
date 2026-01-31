import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:hexcolor/hexcolor.dart';
import '../services/firebase_service.dart';
import '../usersAndItemsModel.dart' as items_model;
import '../widgets/common_widgets.dart';
import 'gudang_item_edit.dart';

class GudangViewStockPage extends StatefulWidget {
  @override
  _GudangViewStockPageState createState() => _GudangViewStockPageState();
}

class _GudangViewStockPageState extends State<GudangViewStockPage> {
  List<items_model.Item>? items;
  final NumberFormat numberFormat = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  Future<void> _refreshItems() async {
    try {
      List<items_model.Item> updatedItems = await FirebaseService().getItems();
      if (mounted) {
        setState(() => items = updatedItems);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat data obat.')));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _refreshItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color brandDark = HexColor("147158");
    Color brandLight = HexColor("6AB29B");

    return Scaffold(
      backgroundColor: Color(0xFFF5F7F8),
      appBar: CommonAppBar(
        title: 'Stok Obat',
        showBackButton: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshItems,
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
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Status Inventaris",
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          SizedBox(height: 4),
                          Text(
                            items == null
                                ? "Memproses..."
                                : "${items!.length} Total Produk",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Search Icon
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.search, color: Colors.white),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // Search Field
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari obat...',
                    hintStyle: TextStyle(color: Colors.white54),
                    prefixIcon: Icon(Icons.search, color: Colors.white54),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  style: TextStyle(color: Colors.white),
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
                    child: (items!.isEmpty
                        ? _buildEmptyState()
                        : _buildItemList(brandDark, brandLight)),
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
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Colors.grey.shade300,
          ),
          SizedBox(height: 16),
          Text("Belum ada data obat.", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildItemList(Color brandDark, Color brandLight) {
    final filteredItems = _searchQuery.isEmpty
        ? items!
        : items!
            .where((item) =>
                item.name.toLowerCase().contains(_searchQuery) ||
                item.type.toLowerCase().contains(_searchQuery))
            .toList();

    if (filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
            SizedBox(height: 16),
            Text("Item tidak ditemukan", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(24),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) => _buildItemCard(
        filteredItems[index],
        brandDark,
        brandLight,
      ),
    );
  }

  Widget _buildItemCard(
    items_model.Item item,
    Color brandDark,
    Color brandLight,
  ) {
    bool lowStock = item.quantity < 10;
    bool criticalStock = item.quantity < 5;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GudangItemDetailPage(item: item),
          ),
        ).then((_) => _refreshItems());
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
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
          border: Border.all(
            color: criticalStock
                ? Colors.red.shade200
                : lowStock
                    ? Colors.orange.shade200
                    : Colors.transparent,
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Section
              Container(
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                  child: item.imagePath != null && item.imagePath!.isNotEmpty
                      ? Image.file(
                          File(item.imagePath!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.medication,
                            color: Colors.grey.shade400,
                            size: 40,
                          ),
                        )
                      : Icon(
                          Icons.medication,
                          color: Colors.grey.shade400,
                          size: 40,
                        ),
                ),
              ),
              // Details Section
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: brandLight.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item.type,
                              style: TextStyle(
                                color: brandDark,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (lowStock)
                            Icon(
                              Icons.warning_amber_rounded,
                              color: criticalStock ? Colors.red : Colors.orange,
                              size: 18,
                            ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        item.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        item.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            numberFormat.format(item.price),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: brandDark,
                              fontSize: 14,
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                              children: [
                                TextSpan(text: "Stok: "),
                                TextSpan(
                                  text: "${item.quantity}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: criticalStock
                                        ? Colors.red
                                        : lowStock
                                            ? Colors.orange
                                            : Colors.green.shade700,
                                  ),
                                ),
                              ],
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
      ),
    );
  }
}


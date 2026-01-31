import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/shared/user_models.dart';
import '../login/login.dart';
import '../providers/user_provider.dart';
import '../widgets/common_widgets.dart';
import '../manager_pages/itemAdd.dart';
import '../services/firebase_service.dart';
import 'stock_transaction_page.dart';
import 'stock_history_page.dart';
import 'gudang_view_stock_page.dart';
import 'low_stock_page.dart';

class GudangHomePage extends StatefulWidget {
  @override
  _GudangHomePageState createState() => _GudangHomePageState();
}

class _GudangHomePageState extends State<GudangHomePage> {
  late DateTime _currentTime;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  String getGreeting() {
    int hour = _currentTime.hour;
    if (hour >= 0 && hour < 12) return 'Selamat Pagi';
    if (hour >= 12 && hour < 17) return 'Selamat Siang';
    if (hour >= 17 && hour < 19) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  @override
  Widget build(BuildContext context) {
    var userData = Provider.of<UserData>(context, listen: false);
    UserBase? loggedInUserBase = userData.loggedInUser;

    if (loggedInUserBase == null) {
      return Scaffold(body: Center(child: Text("Not Logged In")));
    }

    if (loggedInUserBase.type != 'gudang') {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.block, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                "Akses Ditolak",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                "Halaman ini hanya untuk Staff Gudang",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    User user = loggedInUserBase as User;
    Color brandDark = AppColors.brandDark;
    Color brandLight = AppColors.brandLight;

    return Scaffold(
      backgroundColor: Color(0xFFF5F7F8),
      appBar: CommonAppBar(
        title: 'Warehouse Panel',
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () => _showLogoutConfirmation(context, userData),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
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
                    getGreeting(),
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    user.namaLengkap,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Staff Gudang',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Stats
                  _buildQuickStats(brandDark, brandLight),
                  SizedBox(height: 24),
                  Text(
                    "Menu Gudang",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      _buildMenuCard(
                        context,
                        title: "Transaksi Stok",
                        icon: Icons.swap_vert,
                        color: brandDark,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StockTransactionPage(),
                          ),
                        ),
                      ),
                      _buildMenuCard(
                        context,
                        title: "Riwayat Stok",
                        icon: Icons.history,
                        color: brandLight,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StockHistoryPage(),
                          ),
                        ),
                      ),
                      _buildMenuCard(
                        context,
                        title: "Lihat Stok",
                        icon: Icons.inventory_2,
                        color: brandDark,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GudangViewStockPage(),
                          ),
                        ),
                      ),
                      _buildMenuCard(
                        context,
                        title: "Stok Menipis",
                        icon: Icons.warning_amber,
                        color: Colors.orange,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LowStockPage(),
                          ),
                        ),
                      ),
                      _buildMenuCard(
                        context,
                        title: "Tambah Item",
                        icon: Icons.add_circle,
                        color: brandLight,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddItemPage(),
                          ),
                        ),
                      ),
                      _buildMenuCard(
                        context,
                        title: "Scan Barcode",
                        icon: Icons.qr_code_scanner,
                        color: Colors.blue,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Fitur Scan Barcode coming soon')),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(Color brandDark, Color brandLight) {
    return FutureBuilder(
      future: FirebaseService().getItems(),
      builder: (context, snapshot) {
        final items = snapshot.data ?? [];
        final lowStockCount = items.where((item) => item.quantity < 10).length;
        final totalStock = items.fold(0, (sum, item) => sum + item.quantity);

        return Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Icon(Icons.inventory_2, color: brandDark, size: 28),
                    SizedBox(height: 8),
                    Text(
                      "${items.length}",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: brandDark,
                      ),
                    ),
                    Text(
                      "Total Item",
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 50, color: Colors.grey.shade200),
              Expanded(
                child: Column(
                  children: [
                    Icon(Icons.layers, color: Colors.blue, size: 28),
                    SizedBox(height: 8),
                    Text(
                      "$totalStock",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    Text(
                      "Total Stok",
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 50, color: Colors.grey.shade200),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LowStockPage()),
                    );
                  },
                  child: Column(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.orange, size: 28),
                      SizedBox(height: 8),
                      Text(
                        "$lowStockCount",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      Text(
                        "Perlu Alert",
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showLogoutConfirmation(
    BuildContext context,
    UserData userData,
  ) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text('Konfirmasi Logout'),
          content: Text('Apakah Anda yakin ingin keluar?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                userData.logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Ya, Keluar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}


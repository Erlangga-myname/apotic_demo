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
              Text("Access Denied", style: AppTypography.headline),
              SizedBox(height: 8),
              Text("This page is for Warehouse Staff only", style: AppTypography.label),
            ],
          ),
        ),
      );
    }

    User user = loggedInUserBase as User;

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isTablet = constraints.maxWidth >= 600;
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text('Warehouse Dashboard', style: AppTypography.headline.copyWith(color: Colors.white)),
            backgroundColor: AppColors.brandDark,
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(Icons.logout, color: Colors.white),
                onPressed: () => _showLogoutConfirmation(context, userData),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Compact Header
                Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.brandDark,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(getGreeting(), style: AppTypography.label.copyWith(color: Colors.white70)),
                            SizedBox(height: AppSpacing.xs),
                            Text(user.namaLengkap, style: AppTypography.headline.copyWith(color: Colors.white)),
                            SizedBox(height: AppSpacing.sm),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text("Warehouse Staff", style: AppTypography.label.copyWith(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.warehouse, color: Colors.white, size: 48),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.lg),

                // Dense Stats
                Text("Inventory Overview", style: AppTypography.section),
                SizedBox(height: AppSpacing.md),
                FutureBuilder(
                  future: FirebaseService().getItems(),
                  builder: (context, snapshot) {
                    final items = snapshot.data ?? [];
                    final lowStockCount = items.where((item) => item.quantity < 10).length;
                    final totalStock = items.fold(0, (sum, item) => sum + item.quantity);

                    return GridView.count(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: isTablet ? 3 : 2,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisSpacing: AppSpacing.md,
                      childAspectRatio: 1.2,
                      children: [
                        KPICard(
                          title: "Total Items",
                          value: "${items.length}",
                          icon: Icons.inventory_2,
                          color: AppColors.brandDark,
                          trend: "",
                        ),
                        KPICard(
                          title: "Total Stock",
                          value: "$totalStock",
                          icon: Icons.layers,
                          color: Colors.blue,
                          trend: "",
                        ),
                        KPICard(
                          title: "Low Stock Alerts",
                          value: "$lowStockCount",
                          icon: Icons.warning,
                          color: Colors.orange,
                          trend: "",
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: AppSpacing.lg),

                // Quick Actions
                Text("Quick Actions", style: AppTypography.section),
                SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    ActionButton(
                      label: "Stock Transaction",
                      icon: Icons.swap_vert,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => StockTransactionPage())),
                    ),
                    ActionButton(
                      label: "Stock History",
                      icon: Icons.history,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => StockHistoryPage())),
                    ),
                    ActionButton(
                      label: "View Stock",
                      icon: Icons.inventory,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => GudangViewStockPage())),
                    ),
                    ActionButton(
                      label: "Low Stock",
                      icon: Icons.warning_amber,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => LowStockPage())),
                    ),
                    ActionButton(
                      label: "Add Item",
                      icon: Icons.add_circle,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AddItemPage())),
                    ),
                    ActionButton(
                      label: "Scan Barcode",
                      icon: Icons.qr_code_scanner,
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Barcode scan coming soon'))),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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


import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/shared/user_models.dart';
import '../login/login.dart';
import '../providers/user_provider.dart';
import '../widgets/common_widgets.dart';
import 'itemEdit.dart';
import 'itemTypes.dart';
import 'itemView.dart';
import 'manage_users.dart';
import 'financial_reports.dart';

class HomeManagerPage extends StatefulWidget {
  @override
  _HomeManagerPageState createState() => _HomeManagerPageState();
}

class _HomeManagerPageState extends State<HomeManagerPage> {
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

    User user = loggedInUserBase as User;

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isTablet = constraints.maxWidth >= 600;
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text('Manager Dashboard', style: AppTypography.headline.copyWith(color: Colors.white)),
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
                            Text(user.username, style: AppTypography.headline.copyWith(color: Colors.white)),
                            SizedBox(height: AppSpacing.sm),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text("Manager", style: AppTypography.label.copyWith(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.admin_panel_settings, color: Colors.white, size: 48),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.lg),

                // KPI Dashboard
                Text("Key Metrics", style: AppTypography.section),
                SizedBox(height: AppSpacing.md),
                GridView.count(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: isTablet ? 3 : 2,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  childAspectRatio: 1.2,
                  children: [
                    KPICard(
                      title: "Total Items",
                      value: "1,247",
                      icon: Icons.inventory_2,
                      color: Colors.blue,
                      trend: "+12%",
                    ),
                    KPICard(
                      title: "Low Stock Alerts",
                      value: "23",
                      icon: Icons.warning,
                      color: Colors.orange,
                      trend: "+5",
                    ),
                    KPICard(
                      title: "Revenue Today",
                      value: "Rp 2.4M",
                      icon: Icons.attach_money,
                      color: Colors.green,
                      trend: "+8%",
                    ),
                    KPICard(
                      title: "Active Users",
                      value: "156",
                      icon: Icons.people,
                      color: Colors.purple,
                      trend: "+3",
                    ),
                    KPICard(
                      title: "Pending Orders",
                      value: "12",
                      icon: Icons.pending,
                      color: Colors.red,
                      trend: "-2",
                    ),
                    KPICard(
                      title: "Categories",
                      value: "8",
                      icon: Icons.category,
                      color: Colors.teal,
                      trend: "0",
                    ),
                  ],
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
                      label: "Manage Users",
                      icon: Icons.people,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ManageUsersPage())),
                    ),
                    ActionButton(
                      label: "Financial Reports",
                      icon: Icons.payments,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => FinancialReportsPage())),
                    ),
                    ActionButton(
                      label: "View Stock",
                      icon: Icons.inventory,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ViewItemPage())),
                    ),
                    ActionButton(
                      label: "Edit Items",
                      icon: Icons.edit,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EditItemPage())),
                    ),
                    ActionButton(
                      label: "Categories",
                      icon: Icons.category,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EditItemTypePage())),
                    ),
                    ActionButton(
                      label: "Settings",
                      icon: Icons.settings,
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Feature in development"))),
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

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
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
                color: color.withOpacity(0.1),
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
          content: Text('Apakah Anda yakin ingin keluar dari Panel Manager?'),
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

// Add these imports if not already present
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:async';

import 'login/login.dart';
import 'models/shared/user_models.dart';
import 'usersAndItemsModel.dart';
import 'providers/user_provider.dart';

import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'manager_pages/home.dart';
import 'gudang_pages/gudang_home.dart';
import 'kasir_pages/kasir_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(create: (context) => UserData(), child: MyApp()),
  );
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo_512.png', width: 200, height: 200),
            Text(
              "Apotic",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: HexColor("147158"),
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(color: Colors.green),
          ],
        ),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<void> _initializationFuture;

  @override
  void initState() {
    super.initState();
    _initializationFuture = Future.delayed(Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: _initializationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SplashScreen();
          } else {
            final userData = Provider.of<UserData>(context);
            if (userData.isLoggedIn) {
              final user = userData.loggedInUser!;
              switch (user.type) {
                case 'manager':
                  return HomeManagerPage();
                case 'gudang':
                  return GudangHomePage();
                case 'kasir':
                  return KasirHomePage();
                default:
                  return Scaffold(
                    body: Center(
                      child: Text('Tipe user tidak dikenali'),
                    ),
                  );
              }
            } else {
              return LoginPage();
            }
          }
        },
      ),
    );
  }
}

void showGlobalBottomSheet(BuildContext context, Widget page) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(child: page);
    },
  );
}

class Wishlist extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    NumberFormat numberFormat = NumberFormat.decimalPattern('id');
    User loggedInUser = Provider.of<UserData>(context).loggedInUser! as User;

    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        // Fetch the wishlist items from Firebase
        future: firestore.FirebaseFirestore.instance
            .collection('users')
            .doc(loggedInUser.uid)
            .collection('wishlist')
            .get()
            .then((q) => q.docs.map((doc) => doc.data()).toList()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading wishlist'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Wishlist Kamu Kosong.'));
          } else {
            // Build the wishlist items list using a ListView.builder
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> wishlistItem = snapshot.data![index];

                      // Build each wishlist item as a Dismissible widget
                      return Dismissible(
                        key: Key(wishlistItem['id'].toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 16.0),
                              child: Icon(Icons.delete, color: Colors.white),
                            ),
                          ),
                        ),
                        onDismissed: (direction) {
                          firestore.FirebaseFirestore.instance
                              .collection('users')
                              .doc(loggedInUser.uid)
                              .collection('wishlist')
                              .where(
                                'itemName',
                                isEqualTo: wishlistItem['itemName'],
                              )
                              .get()
                              .then((snapshot) {
                                for (var doc in snapshot.docs) {
                                  doc.reference.delete();
                                }
                              });
                        },
                        child: Card(
                          elevation: 4,
                          margin: EdgeInsets.all(8),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Item name and type (top left)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Item name (left top bold)
                                      Text(
                                        wishlistItem['itemName'],
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Item image on the right
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: Image.file(
                                    File(wishlistItem['imagePath']),
                                    height: 80,
                                    width: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

class NotificationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    NumberFormat numberFormat = NumberFormat.decimalPattern('id');
    User loggedInUser = Provider.of<UserData>(context).loggedInUser! as User;

    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        // Fetch the notifications from Firebase
        future: firestore.FirebaseFirestore.instance
            .collection('users')
            .doc(loggedInUser.uid)
            .collection('notifications')
            .get()
            .then(
              (q) => q.docs.map((doc) {
                var d = doc.data();
                d['id'] = doc.id;
                return d;
              }).toList(),
            ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading notifications'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Kamu Tidak Mempunyai Notifikasi.'));
          } else {
            // Build the notifications list using a ListView.builder
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> notificationItem = snapshot.data![index];

                // Get the icon data from the database
                String? iconData = notificationItem['icon'];

                // Build each notification item as a Dismissible widget wrapped in a Container
                return Container(
                  margin: EdgeInsets.all(8), // Add margin to create spacing
                  child: Dismissible(
                    key: Key(notificationItem['id'].toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                      ),
                    ),
                    onDismissed: (direction) {
                      firestore.FirebaseFirestore.instance
                          .collection('users')
                          .doc(loggedInUser.uid)
                          .collection('notifications')
                          .doc(notificationItem['id'])
                          .delete();
                    },
                    child: ListTile(
                      leading: _buildIconFromData(
                        notificationItem['icon'] ?? "failed",
                      ),
                      title: Text(notificationItem['title'] ?? "Placeholder"),
                      subtitle: Text(
                        notificationItem['message'] ?? "Placeholder",
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  // Helper method to build Icon from icon data
  Widget _buildIconFromData(String? iconData) {
    // Use a default icon (e.g., notification icon) if the iconData is not available
    Icon icon = Icon(Icons.abc);

    if (iconData == 'success') {
      icon = Icon(Icons.check_circle, color: Colors.green, size: 40);
    } else if (iconData == 'failed') {
      icon = Icon(Icons.error, color: Colors.red, size: 40);
    }

    return icon;
  }
}

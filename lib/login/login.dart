import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hexcolor/hexcolor.dart';
import '../main.dart';
import './register.dart';
import '../manager_pages/createAccount.dart';
import '../models/shared/user_models.dart';
import '../manager_pages/home.dart';
import '../gudang_pages/gudang_home.dart';
import '../kasir_pages/kasir_home.dart';
import '../services/firebase_service.dart';
import '../providers/user_provider.dart';


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  late FocusNode _passwordFocusNode;
  String? _errorMessage;
  int clickCount = 0;

  late AnimationController controller;
  late Animation<Offset> translateAnimation;

  _LoginPageState() {
    _passwordFocusNode = FocusNode();
  }

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    translateAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.decelerate));
    controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _login(BuildContext context) async {
    var userData = Provider.of<UserData>(context, listen: false);

    print(clickCount);

    if (clickCount == 5) {
      _showCodeInputDialog(context);
      return;
    }

    // Get the username and password from the text controllers
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    // Perform the actual login with Firebase
    User? firebaseUser = await userData.login(username, password) as User?;

    if (firebaseUser != null) {
      clickCount = 0;
      print("Login as User OK via Firebase");

      if (firebaseUser.type == "manager") {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeManagerPage()),
          (route) => false,
        );
      } else if (firebaseUser.type == "gudang") {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => GudangHomePage()),
          (route) => false,
        );
      } else if (firebaseUser.type == "kasir") {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => KasirHomePage()),
          (route) => false,
        );
      } else {
        // Unknown user type
        setState(() {
          _errorMessage = "Tipe user tidak dikenali";
        });
      }
    } else {
      // Login failed or no local user found (migration complete)
      clickCount = 0;
      print("Login Not OK");
      setState(() {
        _errorMessage =
            "Username (Email) atau Password tidak valid. Mohon coba lagi.";
      });
    }
  }

  Future<void> _showCodeInputDialog(BuildContext context) async {
    clickCount = 0;
    String enteredCode = '';

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Code'),
          content: TextField(
            onChanged: (value) {
              enteredCode = value;
            },
            decoration: InputDecoration(labelText: 'Your Code'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Go Back'),
            ),
            TextButton(
              onPressed: () {
                // Perform action based on the entered code
                if (enteredCode == 'sehatselalu') {
                  print("Password OK. going to registeration for manager.");
                  // Use Navigator to navigate to RegistrationManagerPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RegistrationManagerPage(),
                    ),
                  );
                } else {
                  Navigator.of(context).pop();
                  print("popup closed.");
                }

                clickCount = 0;
                print("popup end.");
              },
              child: Text('Go!'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Image.asset('assets/login_bg.png'),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize
                      .min, // Ensures minimum height, avoiding unnecessary scrolling
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      child: Title(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              clickCount++;
                            });
                          },
                          child: Text(
                            "Selamat Datang",
                            textScaleFactor: 2,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: HexColor("147158"),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        color: HexColor("147158"),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      child: Title(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              clickCount = 0;
                            });
                          },
                          child: Text(
                            "Silahkan Login Untuk Mengakses Apotic",
                            textScaleFactor: 1.2,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: HexColor("147158"),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        color: HexColor("147158"),
                      ),
                    ),
                    if (_errorMessage != null) ...[
                      SizedBox(height: 15.0),
                      Container(
                        width: double.infinity,
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                    SizedBox(height: 16.0),
                    Container(
                      width: 300,
                      child: TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: HexColor("147158")),
                          ),
                          labelStyle: TextStyle(color: HexColor("147158")),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Container(
                      width: 300,
                      child: TextField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        focusNode: _passwordFocusNode,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: HexColor("147158")),
                          ),
                          labelStyle: TextStyle(color: HexColor("147158")),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: HexColor("147158"),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.0),
                    ElevatedButton(
                      onPressed: () {
                        _login(context);
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          HexColor("#6AB29B"),
                        ),
                        minimumSize: MaterialStateProperty.all<Size>(
                          Size(200, 50),
                        ),
                      ),
                      child: Text(
                        'Masuk',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegistrationPage(),
                          ),
                        );
                      },
                      child: Text(
                        'Belum Mempunyai Akun? Daftar.',
                        style: TextStyle(color: HexColor("4F6F52")),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

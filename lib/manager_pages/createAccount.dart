// registration_page.dart
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'redirectRegisterAccount.dart';
import '../models/shared/user_models.dart';
import '../services/firebase_service.dart';

class RegistrationManagerPage extends StatefulWidget {
  @override
  _RegistrationManagerPageState createState() =>
      _RegistrationManagerPageState();
}

class _RegistrationManagerPageState extends State<RegistrationManagerPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String? _usernameError;
  String? _passwordError;
  String? _emailError;

  void _registerUser() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();
    String email = _emailController.text.trim();

    // USERNAME VALIDATION
    if (!(RegExp(r'^[a-zA-Z0-9]+$').hasMatch(username))) {
      setState(
        () => _usernameError = 'Hanya huruf dan angka yang diperbolehkan.',
      );
      return;
    } else if (username.length < 2) {
      setState(() => _usernameError = 'Minimal 2 karakter.');
      return;
    } else {
      setState(() => _usernameError = null);
    }

    // EMAIL VALIDATION
    if (email.isEmpty) {
      setState(() => _emailError = 'Email tidak boleh kosong!');
      return;
    } else if (!email.contains('@') || !email.contains('.')) {
      setState(() => _emailError = 'Format email tidak valid!');
      return;
    } else {
      setState(() => _emailError = null);
    }

    // PASSWORD VALIDATION
    if (password.length < 6) {
      setState(() => _passwordError = 'Minimal 6 karakter!');
      return;
    } else {
      setState(() => _passwordError = null);
    }

    UserManager newUser = UserManager(
      username: username,
      password: password,
      email: email,
      type: "manager",
    );

    FirebaseService()
        .register(
          email: email,
          password: password,
          username: username,
          namaLengkap: username,
          alamat: "HQ",
          umur: 99,
          jenisKelamin: "Laki-Laki",
          tanggalLahir: "2000-01-01",
          nomorTelpon: 0,
          type: "manager",
        )
        .then((User? registeredUser) {
          bool isSuccess = registeredUser != null;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => RedirectRegisterPage(
                status: isSuccess ? "success" : "failed",
                user: newUser,
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    Color brandDark = HexColor("147158");

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Daftar Akun Manager',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: brandDark,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: brandDark,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.admin_panel_settings,
                  color: Colors.white,
                  size: 64,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Buat Akun Baru",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: brandDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Silahkan lengkapi data untuk akses manager.",
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32),
                  _buildTextField(
                    controller: _usernameController,
                    label: 'Username',
                    icon: Icons.person_outline,
                    errorText: _usernameError,
                    brandColor: brandDark,
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email Address',
                    icon: Icons.email_outlined,
                    errorText: _emailError,
                    keyboardType: TextInputType.emailAddress,
                    brandColor: brandDark,
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    controller: _passwordController,
                    label: 'Password',
                    icon: Icons.lock_outline,
                    errorText: _passwordError,
                    obscureText: true,
                    brandColor: brandDark,
                  ),
                  SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _registerUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandDark,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      'BUAT AKUN MANAGER',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color brandColor,
    String? errorText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: brandColor.withOpacity(0.7)),
        prefixIcon: Icon(icon, color: brandColor),
        errorText: errorText,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: brandColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
}

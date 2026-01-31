import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import '../models/shared/user_models.dart';

class RedirectRegisterPage extends StatelessWidget {
  final String status;
  final dynamic user;

  RedirectRegisterPage({required this.status, required this.user});

  @override
  Widget build(BuildContext context) {
    Color brandDark = HexColor("147158");
    bool isSuccess = status == "success";

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isSuccess
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSuccess ? Icons.check_circle_outline : Icons.error_outline,
                  color: isSuccess ? Colors.green : Colors.red,
                  size: 100,
                ),
              ),
              SizedBox(height: 32),
              Text(
                isSuccess ? "Registrasi Akun Sukses" : "Registrasi Akun Gagal",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isSuccess ? brandDark : Colors.red.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                isSuccess
                    ? "Selamat, akun manager '${user.username}' berhasil dibuat. Silahkan kembali ke halaman login untuk masuk."
                    : "Mohon maaf, terjadi kesalahan saat mendaftarkan akun. Silahkan coba lagi nanti.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandDark,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    'KEMBALI KE LOGIN',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
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

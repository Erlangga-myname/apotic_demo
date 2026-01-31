import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:hexcolor/hexcolor.dart';
import '../usersAndItemsModel.dart';
import '../services/firebase_service.dart';

class ChangeBannerPage extends StatefulWidget {
  @override
  _ChangeBannerPageState createState() => _ChangeBannerPageState();
}

class _ChangeBannerPageState extends State<ChangeBannerPage> {
  final FirebaseService _firebaseService = FirebaseService();
  bool isBannerSubmitted = false;
  String? _bannerImagePath;

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  void _loadBanner() async {
    final banners = await _firebaseService.getBanners();
    setState(() {
      isBannerSubmitted = banners.isNotEmpty;
      if (isBannerSubmitted) {
        _bannerImagePath = banners.first.filename;
      }
    });
  }

  Future<void> _pickBannerImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        await _firebaseService.addBanner(
          BannerModel(filename: pickedFile.path),
        );
        setState(() {
          _bannerImagePath = pickedFile.path;
          isBannerSubmitted = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Banner berhasil dipasang.'),
            backgroundColor: HexColor("147158"),
          ),
        );
      }
    } catch (e) {
      print('Error picking banner: $e');
    }
  }

  Future<void> _removeBanner() async {
    try {
      final banners = await _firebaseService.getBanners();
      if (banners.isNotEmpty) {
        await _firebaseService.deleteBanner(banners.first.filename);
        setState(() {
          isBannerSubmitted = false;
          _bannerImagePath = null;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Banner berhasil dihapus.')));
      }
    } catch (e) {
      print('Error removing banner: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    Color brandDark = HexColor("147158");

    return Scaffold(
      backgroundColor: Color(0xFFF5F7F8),
      appBar: AppBar(
        title: Text(
          'Banner Promosi',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: brandDark,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
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
            child: Text(
              "Banner ini akan ditampilkan di halaman utama pelanggan sebagai promosi utama.",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSectionTitle("Preview Banner Saat Ini"),
                SizedBox(height: 16),
                _buildBannerCard(brandDark),
                SizedBox(height: 48),
                _buildActionButtons(brandDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black54,
      ),
    );
  }

  Widget _buildBannerCard(Color brandDark) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: isBannerSubmitted && _bannerImagePath != null
            ? Image.file(
                File(_bannerImagePath!),
                fit: BoxFit.cover,
                width: double.infinity,
              )
            : Container(
                color: Colors.grey.shade50,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 64,
                      color: Colors.grey.shade300,
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Belum Ada Banner Aktif",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildActionButtons(Color brandDark) {
    return Column(
      children: [
        if (isBannerSubmitted)
          ElevatedButton.icon(
            onPressed: _pickBannerImage,
            style: ElevatedButton.styleFrom(
              backgroundColor: brandDark,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              minimumSize: Size(double.infinity, 56),
            ),
            icon: Icon(Icons.edit, color: Colors.white),
            label: Text(
              "GANTI BANNER",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        else
          ElevatedButton.icon(
            onPressed: _pickBannerImage,
            style: ElevatedButton.styleFrom(
              backgroundColor: brandDark,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              minimumSize: Size(double.infinity, 56),
            ),
            icon: Icon(Icons.upload, color: Colors.white),
            label: Text(
              "UNGGAH BANNER BARU",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        if (isBannerSubmitted)
          TextButton.icon(
            onPressed: _removeBanner,
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 20),
            ),
            icon: Icon(Icons.delete_outline, color: Colors.redAccent),
            label: Text(
              "Hapus Banner Aktif",
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}

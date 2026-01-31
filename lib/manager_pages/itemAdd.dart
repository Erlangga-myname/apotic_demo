 import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';

import '../usersAndItemsModel.dart';
import '../services/firebase_service.dart';
import 'itemRedirect.dart';
import 'itemTypes.dart';

class AddItemPage extends StatefulWidget {
  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  String itemName = '';
  String itemType = '';
  String itemDescription = '';
  int itemPrice = 0;
  int itemQuantity = 0;

  String? _itemNameError;
  String? _itemTypeError;
  String? _itemPriceError;
  String? _itemQuantityError;
  String? _itemDescriptionError;
  String? _imagePath;

  bool isImageSubmitted = false;

  void _sumbitItem() async {
    bool hasError = false;

    // ITEM NAME VALIDATION
    if (itemName.isEmpty) {
      setState(() => _itemNameError = "Nama Obat Tidak Boleh Kosong");
      hasError = true;
    } else if (itemName.length <= 3) {
      setState(() => _itemNameError = "Nama Obat Terlalu Pendek");
      hasError = true;
    } else {
      setState(() => _itemNameError = null);
    }

    // ITEM TYPE VALIDATION
    if (itemType.isEmpty) {
      setState(() => _itemTypeError = "Tipe Obat Tidak Boleh Kosong");
      hasError = true;
    } else {
      setState(() => _itemTypeError = null);
    }

    // ITEM PRICE VALIDATION
    if (itemPrice <= 0) {
      setState(() => _itemPriceError = "Harga Harus Lebih Besar Dari 0");
      hasError = true;
    } else {
      setState(() => _itemPriceError = null);
    }

    // ITEM QUANTITY VALIDATION
    if (itemQuantity <= 0) {
      setState(() => _itemQuantityError = "Jumlah Harus Lebih Besar Dari 0");
      hasError = true;
    } else {
      setState(() => _itemQuantityError = null);
    }

    // IMAGE ITEM VALIDATION
    if (_imagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pilih gambar Obat terlebih dahulu.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (hasError) return;

    if (itemDescription.isEmpty) {
      itemDescription = "Deskripsi obat belum tersedia.";
    }

    final newItem = Item(
      name: itemName,
      type: itemType,
      description: itemDescription,
      price: itemPrice,
      quantity: itemQuantity,
      imagePath: _imagePath,
    );

    try {
      await FirebaseService().addItem(newItem);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ItemRedirectPage(
            status: "success",
            title: "Penambahan Obat Sukses",
          ),
        ),
      );
    } catch (e) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ItemRedirectPage(
            status: "failure",
            title: "Penambahan Obat Gagal",
          ),
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        setState(() {
          _imagePath = pickedFile.path;
          isImageSubmitted = true;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    Color brandDark = HexColor("147158");
    Color brandLight = HexColor("6AB29B");

    return Scaffold(
      backgroundColor: Color(0xFFF5F7F8),
      appBar: AppBar(
        title: Text(
          'Tambah Obat Baru',
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
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: brandDark,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Text(
                "Masukkan detail obat secara lengkap untuk ditambahkan ke stok toko.",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                padding: EdgeInsets.all(24),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionTitle("Informasi Dasar"),
                    SizedBox(height: 16),
                    _buildTextField(
                      label: 'Nama Obat',
                      icon: Icons.medication_outlined,
                      errorText: _itemNameError,
                      onChanged: (value) => itemName = value,
                      brandColor: brandDark,
                    ),
                    SizedBox(height: 16),
                    _buildTypeDropdown(brandDark),
                    if (_itemTypeError != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 12, top: 4),
                        child: Text(
                          _itemTypeError!,
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    SizedBox(height: 24),
                    _buildSectionTitle("Inventaris & Harga"),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: 'Harga (Rp)',
                            icon: Icons.payments_outlined,
                            errorText: _itemPriceError,
                            keyboardType: TextInputType.number,
                            onChanged: (value) =>
                                itemPrice = int.tryParse(value) ?? 0,
                            brandColor: brandDark,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            label: 'Jumlah Stok',
                            icon: Icons.inventory_2_outlined,
                            errorText: _itemQuantityError,
                            keyboardType: TextInputType.number,
                            onChanged: (value) =>
                                itemQuantity = int.tryParse(value) ?? 0,
                            brandColor: brandDark,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      label: 'Deskripsi Obat',
                      icon: Icons.description_outlined,
                      errorText: _itemDescriptionError,
                      maxLines: 3,
                      onChanged: (value) => itemDescription = value,
                      brandColor: brandDark,
                    ),
                    SizedBox(height: 24),
                    _buildSectionTitle("Media"),
                    SizedBox(height: 16),
                    _buildImagePicker(brandDark, brandLight),
                    SizedBox(height: 40),
                    ElevatedButton.icon(
                      onPressed: _sumbitItem,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandDark,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      icon: Icon(Icons.add_task, color: Colors.white),
                      label: Text(
                        'TAMBAHKAN KE KATALOG',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
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

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required Color brandColor,
    String? errorText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    required Function(String) onChanged,
  }) {
    return TextField(
      onChanged: onChanged,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: brandColor),
        errorText: errorText,
        filled: true,
        fillColor: Colors.grey.shade50,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: brandColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red.shade200),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildTypeDropdown(Color brandColor) {
    return FutureBuilder<List<TypeItem>>(
      future: FirebaseService().getItemTypes(),
      builder: (context, snapshot) {
        final List<String> itemTypes =
            snapshot.data?.map((e) => e.type).toList() ?? [];
        if (itemTypes.isEmpty)
          itemTypes.addAll(['Obat Bebas', 'Obat Keras', 'Vitamin']);

        return DropdownButtonFormField2<String>(
          decoration: InputDecoration(
            labelText: 'Kategori Obat',
            prefixIcon: Icon(Icons.category_outlined, color: brandColor),
            filled: true,
            fillColor: Colors.grey.shade50,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: brandColor, width: 1.5),
            ),
          ),
          hint: Text('Pilih Kategori'),
          items: [
            ...itemTypes.map(
              (String item) =>
                  DropdownMenuItem<String>(value: item, child: Text(item)),
            ),
            DropdownMenuItem<String>(
              value: 'Buat Baru',
              child: Text(
                'Buat Baru...',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          value: itemType.isNotEmpty ? itemType : null,
          onChanged: (String? value) {
            if (value == 'Buat Baru') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditItemTypePage()),
              ).then((_) => setState(() {}));
            } else {
              setState(() => itemType = value ?? '');
            }
          },
        );
      },
    );
  }

  Widget _buildImagePicker(Color brandColor, Color brandLight) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: _imagePath == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 48,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Pilih Gambar Obat",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(File(_imagePath!), fit: BoxFit.cover),
                    Container(color: Colors.black26),
                    Center(
                      child: Icon(Icons.edit, color: Colors.white, size: 32),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

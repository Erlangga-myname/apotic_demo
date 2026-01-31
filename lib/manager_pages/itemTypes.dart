import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import '../usersAndItemsModel.dart';
import '../services/firebase_service.dart';

class EditItemTypePage extends StatefulWidget {
  @override
  _EditItemTypePageState createState() => _EditItemTypePageState();
}

class _EditItemTypePageState extends State<EditItemTypePage> {
  final FirebaseService _firebaseService = FirebaseService();
  List<TypeItem>? types;

  Future<void> _refreshTypes() async {
    try {
      List<TypeItem> updatedTypes = await _firebaseService.getItemTypes();
      setState(() => types = updatedTypes);
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memproses data kategori.')));
    }
  }

  @override
  void initState() {
    super.initState();
    _refreshTypes();
  }

  @override
  Widget build(BuildContext context) {
    Color brandDark = HexColor("147158");

    return Scaffold(
      backgroundColor: Color(0xFFF5F7F8),
      appBar: AppBar(
        title: Text(
          'Kategori Produk',
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
              "Kelola daftar kategori produk untuk memudahkan pengelompokan obat-obatan.",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshTypes,
              color: brandDark,
              child: types == null
                  ? Center(child: CircularProgressIndicator(color: brandDark))
                  : types!.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: EdgeInsets.all(24),
                      itemCount: types!.length,
                      itemBuilder: (context, index) =>
                          _buildTypeCard(types![index], brandDark),
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTypeDialog(context),
        backgroundColor: brandDark,
        icon: Icon(Icons.add, color: Colors.white),
        label: Text(
          "TAMBAH KATEGORI",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category_outlined, size: 64, color: Colors.grey.shade300),
          SizedBox(height: 16),
          Text("Belum ada kategori.", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildTypeCard(TypeItem type, Color brandDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
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
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: brandDark.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.label_important_outline,
            color: brandDark,
            size: 20,
          ),
        ),
        title: Text(
          type.type,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit_note),
              onPressed: () => _showEditModal(context, type),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () => _showDeleteConfirmation(context, type),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditModal(BuildContext context, TypeItem type) {
    final TextEditingController typeController = TextEditingController(
      text: type.type,
    );
    Color brandDark = HexColor("147158");

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Edit Kategori',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: brandDark,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              TextField(
                controller: typeController,
                decoration: InputDecoration(
                  labelText: 'Nama Kategori',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: brandDark),
                  ),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (typeController.text.trim().isEmpty) return;
                  try {
                    await _firebaseService.deleteItemType(type.type);
                    await _firebaseService.addItemType(
                      TypeItem(type: typeController.text.trim()),
                    );
                    Navigator.pop(context);
                    _refreshTypes();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal memperbarui kategori.')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandDark,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'SIMPAN PERUBAHAN',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, TypeItem type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text("Hapus Kategori?"),
        content: Text(
          "Menghapus kategori '${type.type}' mungkin mempengaruhi pengelompokan produk yang sudah ada.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("BATAL", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              await _firebaseService.deleteItemType(type.type);
              Navigator.pop(context);
              _refreshTypes();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text("HAPUS", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddTypeDialog(BuildContext context) {
    final TextEditingController typeController = TextEditingController();
    Color brandDark = HexColor("147158");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text("Tambah Kategori Baru"),
        content: TextField(
          controller: typeController,
          decoration: InputDecoration(
            hintText: "Nama Kategori (Contoh: Vitamin)",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("BATAL", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (typeController.text.trim().isEmpty) return;
              await _firebaseService.addItemType(
                TypeItem(type: typeController.text.trim()),
              );
              Navigator.pop(context);
              _refreshTypes();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: brandDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text("TAMBAH", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

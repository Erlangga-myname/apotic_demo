import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import '../models/shared/user_models.dart';
import '../services/firebase_service.dart';

class ManageUsersPage extends StatefulWidget {
  @override
  _ManageUsersPageState createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  final FirebaseService _firebaseService = FirebaseService();
  List<User>? _users;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() async {
    try {
      List<User> users = await _firebaseService.getAllUsers();
      setState(() => _users = users);
    } catch (e) {
      print("Error loading users: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    Color brandDark = HexColor("147158");

    return Scaffold(
      backgroundColor: Color(0xFFF5F7F8),
      appBar: AppBar(
        title: Text(
          'Kelola User & Role',
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
              "Daftar pengguna terdaftar di system beserta peran (role) mereka.",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
          Expanded(
            child: _users == null
                ? Center(child: CircularProgressIndicator(color: brandDark))
                : _users!.isEmpty
                ? Center(child: Text("Belum ada user."))
                : ListView.builder(
                    padding: EdgeInsets.all(24),
                    itemCount: _users!.length,
                    itemBuilder: (context, index) =>
                        _buildUserCard(_users![index], brandDark),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddUserDialog(context, brandDark),
        backgroundColor: brandDark,
        icon: Icon(Icons.person_add, color: Colors.white),
        label: Text(
          "TAMBAH USER",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildUserCard(User user, Color brandDark) {
    Color roleColor;
    switch (user.type) {
      case 'manager':
        roleColor = Colors.redAccent;
        break;
      case 'gudang':
        roleColor = Colors.blueAccent;
        break;
      case 'kasir':
        roleColor = Colors.orangeAccent;
        break;
      default:
        roleColor = HexColor("6AB29B");
    }

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
        leading: CircleAvatar(
          backgroundColor: roleColor.withOpacity(0.1),
          child: Icon(Icons.person, color: roleColor),
        ),
        title: Text(
          user.username,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(user.email, style: TextStyle(fontSize: 12)),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: roleColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            user.type.toUpperCase(),
            style: TextStyle(
              color: roleColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _showAddUserDialog(BuildContext context, Color brandDark) {
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    String selectedRole = 'kasir';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text("Tambah User Baru"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(labelText: "Username"),
                ),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: "Email"),
                ),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(labelText: "Password"),
                  obscureText: true,
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  items: [
                    DropdownMenuItem(value: 'kasir', child: Text("Kasir")),
                    DropdownMenuItem(
                      value: 'gudang',
                      child: Text("Managemen Gudang"),
                    ),
                    DropdownMenuItem(value: 'manager', child: Text("Manager")),
                    DropdownMenuItem(
                      value: 'customer',
                      child: Text("Customer"),
                    ),
                  ],
                  onChanged: (val) => setState(() => selectedRole = val!),
                  decoration: InputDecoration(labelText: "Role"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("BATAL", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (usernameController.text.isEmpty ||
                    emailController.text.isEmpty ||
                    passwordController.text.isEmpty)
                  return;

                User? newUser = await _firebaseService.register(
                  email: emailController.text.trim(),
                  password: passwordController.text.trim(),
                  username: usernameController.text.trim(),
                  namaLengkap: usernameController.text.trim(),
                  alamat: "Store Account",
                  umur: 0,
                  jenisKelamin: "Universal",
                  tanggalLahir: "2000-01-01",
                  nomorTelpon: 0,
                  type: selectedRole,
                );

                if (newUser != null) {
                  Navigator.pop(context);
                  _loadUsers();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("User berhasil ditambahkan!")),
                  );
                }
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
      ),
    );
  }
}

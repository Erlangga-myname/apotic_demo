import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shared/user_models.dart';
import '../usersAndItemsModel.dart' hide User;

class FirebaseService {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- AUTHENTICATION & USERS ---

  Future<User?> login(String email, String password) async {
    try {
      auth.UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      auth.User? firebaseUser = result.user;
      if (firebaseUser != null) {
        return await getUserById(firebaseUser.uid);
      }
    } catch (e) {
      print("Login Error: $e");
    }
    return null;
  }

  Future<User?> register({
    required String email,
    required String password,
    required String username,
    required String namaLengkap,
    required String alamat,
    required int umur,
    required String jenisKelamin,
    required String tanggalLahir,
    required int nomorTelpon,
    required String type,
  }) async {
    try {
      auth.UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      auth.User? firebaseUser = result.user;

      if (firebaseUser != null) {
        User newUser = User(
          id: 0,
          uid: firebaseUser.uid,
          username: username,
          password: password,
          email: email,
          namaLengkap: namaLengkap,
          alamat: alamat,
          umur: umur,
          jenisKelamin: jenisKelamin,
          tanggalLahir: tanggalLahir,
          nomorTelpon: nomorTelpon,
          type: type,
        );

        await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .set(newUser.toMap());
        return newUser;
      }
    } catch (e) {
      print("Register Error: $e");
    }
    return null;
  }

  Future<User?> getUserById(String uid) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return User.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<List<User>> getAllUsers() async {
    QuerySnapshot snapshot = await _firestore.collection('users').get();
    return snapshot.docs
        .map((doc) => User.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteUser(String uid) async {
    // Note: This only deletes from Firestore. Deleting from Auth requires Admin SDK or being logged in as that user.
    await _firestore.collection('users').doc(uid).delete();
  }

  // --- TRANSACTIONS (Financial Reports) ---

  Future<void> addTransaction(TransactionModel transaction) async {
    await _firestore.collection('transactions').add(transaction.toMap());
  }

  Future<List<TransactionModel>> getTransactions() async {
    QuerySnapshot snapshot = await _firestore
        .collection('transactions')
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs
        .map(
          (doc) => TransactionModel.fromMap(
            doc.data() as Map<String, dynamic>,
            doc.id,
          ),
        )
        .toList();
  }

  // --- ITEMS ---

  Future<List<Item>> getItems() async {
    QuerySnapshot snapshot = await _firestore.collection('items').get();
    return snapshot.docs
        .map((doc) => Item.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<void> addItem(Item item) async {
    await _firestore.collection('items').add(item.toMap());
  }

  // --- CART ---

  Future<void> addToCart(String uid, CartItem item) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('cart')
        .add(item.toMap());
  }

  Future<List<CartItem>> getCart(String uid) async {
    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('cart')
        .get();
    return snapshot.docs
        .map(
          (doc) => CartItem.fromMap(doc.data() as Map<String, dynamic>, doc.id),
        )
        .toList();
  }

  // --- WISHLIST ---

  Future<void> addToWishlist(
    String uid,
    String itemName,
    String imagePath,
  ) async {
    await _firestore.collection('users').doc(uid).collection('wishlist').add({
      'itemName': itemName,
      'imagePath': imagePath,
    });
  }

  Future<Map<String, List<Item>>> getItemsByCategory() async {
    QuerySnapshot snapshot = await _firestore.collection('items').get();
    Map<String, List<Item>> categoryMap = {};
    for (var doc in snapshot.docs) {
      Item item = Item.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      if (!categoryMap.containsKey(item.type)) {
        categoryMap[item.type] = [];
      }
      categoryMap[item.type]!.add(item);
    }
    return categoryMap;
  }

  Future<void> updateItemQuantity(String docId, int quantity) async {
    await _firestore.collection('items').doc(docId).update({
      'quantity': quantity,
    });
  }

  Future<void> deleteItem(String docId) async {
    await _firestore.collection('items').doc(docId).delete();
  }

  Future<void> updateItem(Item item) async {
    if (item.docId != null) {
      await _firestore.collection('items').doc(item.docId).update(item.toMap());
    }
  }

  // --- BANNERS ---

  Future<List<BannerModel>> getBanners() async {
    QuerySnapshot snapshot = await _firestore.collection('banners').get();
    return snapshot.docs
        .map((doc) => BannerModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> addBanner(BannerModel banner) async {
    await _firestore.collection('banners').add(banner.toMap());
  }

  Future<void> deleteBanner(String filename) async {
    QuerySnapshot snapshot = await _firestore
        .collection('banners')
        .where('filename', isEqualTo: filename)
        .get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  // --- ITEM TYPES ---

  Future<List<TypeItem>> getItemTypes() async {
    QuerySnapshot snapshot = await _firestore.collection('item_types').get();
    return snapshot.docs
        .map((doc) => TypeItem.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> addItemType(TypeItem type) async {
    await _firestore.collection('item_types').add(type.toMap());
  }

  Future<void> deleteItemType(String typeName) async {
    QuerySnapshot snapshot = await _firestore
        .collection('item_types')
        .where('type', isEqualTo: typeName)
        .get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}

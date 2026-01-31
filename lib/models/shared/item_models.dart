import 'package:cloud_firestore/cloud_firestore.dart';

// Shared item models used by all roles
class Item {
  int? id;
  String? docId;
  String name;
  String type;
  String description;
  int price;
  int quantity;
  String? imagePath;

  Item({
    this.id,
    this.docId,
    required this.name,
    required this.type,
    required this.description,
    required this.price,
    required this.quantity,
    this.imagePath,
  });

  factory Item.fromMap(Map<String, dynamic> map, String docId) {
    return Item(
      docId: docId,
      id: null,
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      description: map['description'] ?? '',
      price: map['price'] ?? 0,
      quantity: map['quantity'] ?? 0,
      imagePath: map['imagePath'] ?? '',
    );
  }

  Item copyWith({
    int? id,
    String? name,
    String? type,
    String? description,
    int? price,
    int? quantity,
    String? imagePath,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'description': description,
      'price': price,
      'quantity': quantity,
      'imagePath': imagePath,
    };
  }
}

class TypeItem {
  int? id;
  String type;

  TypeItem({this.id, required this.type});

  factory TypeItem.fromMap(Map<String, dynamic> map) {
    return TypeItem(id: null, type: map['type'] ?? '');
  }

  TypeItem copyWith({int? id, String? type}) {
    return TypeItem(id: id ?? this.id, type: type ?? this.type);
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'type': type};
  }
}

class CartItem {
  int? id;
  String name;
  int quantity;
  int price;
  bool isSelected;
  String? imagePath;

  CartItem({
    this.id,
    required this.name,
    required this.quantity,
    required this.price,
    this.isSelected = true,
    this.imagePath,
  });

  factory CartItem.fromMap(Map<String, dynamic> map, String docId) {
    return CartItem(
      id: null,
      name: map['itemName'] ?? '',
      quantity: map['quantity'] ?? 0,
      price: map['price'] ?? 0,
      isSelected: map['isSelected'] == 1,
      imagePath: map['imagePath'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemName': name,
      'quantity': quantity,
      'price': price,
      'isSelected': isSelected ? 1 : 0,
      'imagePath': imagePath,
    };
  }
}

class BannerModel {
  final String filename;

  BannerModel({required this.filename});

  Map<String, dynamic> toMap() {
    return {'filename': filename};
  }

  factory BannerModel.fromMap(Map<String, dynamic> map) {
    return BannerModel(filename: map['filename']);
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class LocalProduce {
  String pid;  // Changed from String? to String
  String productName;
  double price;
  String description;
  List<String> imageUrls;
  int stock;
  DateTime expiryDate;
  DocumentReference? userRef;
  String status;
  String? category;
  double? weight;
  String? unit;
  DateTime createdAt;
  DateTime updatedAt;

  LocalProduce({
    required this.pid,  // Made required
    required this.productName,
    required this.price,
    required this.description,
    required this.imageUrls,
    required this.stock,
    required this.expiryDate,
    this.status = 'available',
    this.userRef,
    this.category,
    this.weight,
    this.unit = 'kg',
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    this.createdAt = createdAt ?? DateTime.now(),
    this.updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'pid': pid,
      'productName': productName,
      'price': price,
      'description': description,
      'imageUrls': imageUrls,
      'stock': stock,
      'expiryDate': Timestamp.fromDate(expiryDate),
      'status': status,
      'userRef': userRef,
      'category': category,
      'weight': weight,
      'unit': unit,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory LocalProduce.fromJson(Map<String, dynamic> json) {
    return LocalProduce(
      pid: json['pid'] as String,  // Changed from String? to String
      productName: json['productName'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String,
      imageUrls: List<String>.from(json['imageUrls'] as List),
      stock: json['stock'] as int,
      expiryDate: (json['expiryDate'] as Timestamp).toDate(),
      status: json['status'] as String? ?? 'available',
      userRef: json['userRef'] as DocumentReference?,
      category: json['category'] as String?,
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      unit: json['unit'] as String? ?? 'kg',
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  void updateStock(int newStock) {
    stock = newStock;
    if (stock <= 0) {
      status = 'out of stock';
    } else {
      status = 'available';
    }
    updatedAt = DateTime.now();
  }

  bool isExpired() {
    return DateTime.now().isAfter(expiryDate);
  }

  void checkAndUpdateStatus() {
    if (isExpired()) {
      status = 'recycled';
    } else if (stock <= 0) {
      status = 'out of stock';
    } else {
      status = 'available';
    }
    updatedAt = DateTime.now();
  }

  LocalProduce copyWith({
    String? pid,
    String? productName,
    double? price,
    String? description,
    List<String>? imageUrls,
    int? stock,
    DateTime? expiryDate,
    String? status,
    DocumentReference? userRef,
    String? category,
    double? weight,
    String? unit,
  }) {
    return LocalProduce(
      pid: pid ?? this.pid,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      description: description ?? this.description,
      imageUrls: imageUrls ?? List.from(this.imageUrls),
      stock: stock ?? this.stock,
      expiryDate: expiryDate ?? this.expiryDate,
      status: status ?? this.status,
      userRef: userRef ?? this.userRef,
      category: category ?? this.category,
      weight: weight ?? this.weight,
      unit: unit ?? this.unit,
      updatedAt: DateTime.now(),
    );
  }
}
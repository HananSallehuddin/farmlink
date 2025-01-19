import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmlink/models/LocalProduce.dart';

class Cart {
  final String cid;
  List<LocalProduce> produces;
  Map<String, int> quantity;
  double discount;
  String status;
  DateTime timestamp;
  String? shippingAddress;
  double totalAmount;
  String paymentMethod;

  Cart({
    required this.cid,
    required this.produces,
    required this.quantity,
    required this.discount,
    required this.status,
    required this.timestamp,
    this.shippingAddress,
    this.totalAmount = 0.0,
    this.paymentMethod = 'Cash on Delivery',
  });

  Map<String, dynamic> toJson() {
    return {
      'cid': cid,
      'produces': produces.map((produce) => produce.toJson()).toList(),
      'quantity': quantity,
      'discount': discount,
      'status': status,
      'timestamp': Timestamp.fromDate(timestamp),
      'shippingAddress': shippingAddress,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
    };
  }

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      cid: json['cid'] as String,
      produces: (json['produces'] as List? ?? [])
          .map((produceJson) => LocalProduce.fromJson(produceJson as Map<String, dynamic>))
          .toList(),
      quantity: Map<String, int>.from(json['quantity'] as Map? ?? {}),
      discount: (json['discount'] ?? 0.0) as double,
      status: json['status'] as String,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      shippingAddress: json['shippingAddress'] as String?,
      totalAmount: (json['totalAmount'] ?? 0.0) as double,
      paymentMethod: json['paymentMethod'] as String? ?? 'Cash on Delivery',
    );
  }

  void calculateTotalAmount() {
    totalAmount = produces.fold(0.0, (sum, produce) {
      int qty = quantity[produce.pid] ?? 0;
      return sum + (produce.price * qty);
    });
    
    // Apply discount if any
    if (discount > 0) {
      totalAmount = totalAmount * (1 - discount / 100);
    }
  }

  bool isExpired() {
    final now = DateTime.now();
    final expirationTime = timestamp.add(const Duration(hours: 24));
    return now.isAfter(expirationTime);
  }

  void clear() {
    produces.clear();
    quantity.clear();
    totalAmount = 0.0;
    discount = 0.0;
    timestamp = DateTime.now();
  }
}
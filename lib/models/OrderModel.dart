import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String orderId;
  final DateTime orderDate;
  final String paymentMethod;
  final List<Map<String, dynamic>> products;
  Map<String, dynamic> quantities;  // Removed final
  final List<String> sellerIds;
  final String shippingAddress;
  final double totalAmount;
  final String userId;
  String status;  // Removed final, so status can be updated
  final DateTime lastUpdated;

  OrderModel({
    required this.orderId,
    required this.orderDate,
    required this.paymentMethod,
    required this.products,
    required this.quantities,
    required this.sellerIds,
    required this.shippingAddress,
    required this.totalAmount,
    required this.userId,
    this.status = 'pending',  // Default value for status
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'orderDate': Timestamp.fromDate(orderDate),
      'paymentMethod': paymentMethod,
      'products': products,
      'quantities': quantities,
      'sellerIds': sellerIds,
      'shippingAddress': shippingAddress,
      'totalAmount': totalAmount,
      'userId': userId,
      'status': status,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['orderId'] as String,
      orderDate: (json['orderDate'] as Timestamp).toDate(),
      paymentMethod: json['paymentMethod'] as String,
      products: List<Map<String, dynamic>>.from(json['products'] ?? []),
      quantities: Map<String, dynamic>.from(json['quantities'] ?? {}),
      sellerIds: List<String>.from(json['sellerIds'] ?? []),
      shippingAddress: json['shippingAddress'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      userId: json['userId'] as String,
      status: json['status'] as String? ?? 'pending',  // Default value for status
      lastUpdated: (json['lastUpdated'] as Timestamp).toDate(),
    );
  }
}
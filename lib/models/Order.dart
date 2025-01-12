import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmlink/models/LocalProduce.dart';

class Order {
  final String oid;
  List<LocalProduce> produces;
  double totalPrice;
  DateTime orderDate;
  String status;
  final DocumentReference addressRef;
  final DocumentReference customerRef; 
  final Map<String, int> quantities;  

  Order({
    required this.oid,
    required this.produces,
    required this.totalPrice,
    required this.orderDate,
    this.status = 'pending',
    required this.addressRef,
    required this.customerRef,
    required this.quantities,
  });

  Map<String, dynamic> toJson() {
    return {
      'oid': oid,
      'produces': produces.map((produce) => produce.toJson()).toList(),
      'totalPrice': totalPrice,
      'orderDate': Timestamp.fromDate(orderDate),
      'status': status,
      'addressRef': addressRef,
      'customerRef': customerRef, 
      'quantities': quantities,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    DocumentReference addressRef = json['addressRef'] is DocumentReference
        ? json['addressRef'] as DocumentReference
        : FirebaseFirestore.instance.doc(json['addressRef'] as String);

    DocumentReference customerRef = json['customerRef'] is DocumentReference
        ? json['customerRef'] as DocumentReference
        : FirebaseFirestore.instance.doc(json['customerRef'] as String);

    return Order(
      oid: json['oid'] as String,
      produces: (json['produces'] as List? ?? [])
          .map((produceJson) => LocalProduce.fromJson(produceJson as Map<String, dynamic>))
          .toList(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      orderDate: (json['orderDate'] as Timestamp).toDate(),
      status: json['status'] as String? ?? 'pending',
      addressRef: addressRef,
      customerRef: customerRef,
      quantities: json['quantities'] != null 
          ? Map<String, int>.from(json['quantities']) 
          : {},
    );
  }
}
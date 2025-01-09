import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmlink/models/LocalProduce.dart';

class Order {
    final String oid;
    List<LocalProduce> produces;
    double totalPrice;
    DateTime orderDate;
    String status;
    final DocumentReference addressRef;

    Order({
      required this.oid,
      required this.produces,
      required this.totalPrice,
      required this.orderDate,
      this.status = 'pending',
      required this.addressRef,
    });

    Map<String, dynamic> toJson() {
      return{
        'oid': oid,
        'produces': produces.map((produce) => produce.toJson()).toList(),
        'totalPrice':totalPrice,
        'orderDate': Timestamp.fromDate(orderDate),
        'status': status,
        'addressRef': addressRef,
      };
    }

    factory Order.fromJson(Map<String, dynamic> json) {
      return Order( 
        oid: json['oid'] as String,
        produces: (json['produces'] as List? ?? [])
          .map((produceJson) => LocalProduce.fromJson(produceJson as Map<String, dynamic>))
          .toList(),
        totalPrice: (json['totalPrice'] as num).toDouble(),
        orderDate: (json['orderDate'] as Timestamp).toDate(),
        status: json['status'] as String? ?? 'pending',
        addressRef: json['addressRef'] as DocumentReference,
      );
    }
}
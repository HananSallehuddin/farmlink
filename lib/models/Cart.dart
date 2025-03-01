import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmlink/models/LocalProduce.dart';

class Cart {
  final String cid;
  List<LocalProduce> produces; //list of localproduce objects
  Map<String, int> quantity; //map to store quantity of each produce (using pid as key)
  double discount;
  String status; //cart status
  DateTime timestamp;

  Cart({
    required this.cid,
    required this.produces,
    required this.quantity,
    required this.discount,
    required this.status,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'cid': cid,
      'produces': produces.map((produce) => produce.toJson()).toList(),
      'quantity': quantity,
      'discount': discount,
      'status': status,
      'timestamp': Timestamp.fromDate(timestamp), //convert timestamp to firestore format
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
    );
  }
}


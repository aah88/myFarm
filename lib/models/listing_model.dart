import 'package:cloud_firestore/cloud_firestore.dart';

class Listing {
  final String id;
  final int totalAmount;
  final String paymentStatus; 
  final String deliveryStatus;
  final Timestamp orderDate;

  Listing({required this.id,
    required this.totalAmount,
    required this.paymentStatus,
    required this.deliveryStatus,
    required this.orderDate,
    });

  factory Listing.fromMap(Map<String, dynamic> data, String id) {
    return Listing(
      id: id,
      totalAmount: data['totalAmount'] ?? 0,
      paymentStatus: data['paymentStatus']?? '',
      deliveryStatus: data['deliveryStatus']?? '',
      orderDate: data['orderDate']?? FieldValue.serverTimestamp(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalAmount': totalAmount,
      'paymentStatus': paymentStatus,
      'deliveryStatus': deliveryStatus,
      'orderDate': orderDate,
    };
  }
}
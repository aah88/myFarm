import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String id;
  final List<OrderItem> orderItems;
  final int totalAmount;
  final String paymentStatus; 
  final String deliveryStatus;
  final Timestamp orderDate;

  Order({required this.id,
    required this.orderItems,
    required this.totalAmount,
    required this.paymentStatus,
    required this.deliveryStatus,
    required this.orderDate,
    });

  factory Order.fromMap(Map<String, dynamic> data, String id) {
    return Order(
      id: id,
      orderItems: data['orderItems'] ?? [],
      totalAmount: data['totalAmount'] ?? 0,
      paymentStatus: data['paymentStatus']?? '',
      deliveryStatus: data['deliveryStatus']?? '',
      orderDate: data['orderDate']?? FieldValue.serverTimestamp(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderItems': orderItems,
      'totalAmount': totalAmount,
      'paymentStatus': paymentStatus,
      'deliveryStatus': deliveryStatus,
      'orderDate': orderDate,
    };
  }
}

class OrderItem{
  final String productId;
   final String name;
  final int quantity;
  final int unitPrice;

  OrderItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.unitPrice
    });

  factory OrderItem.fromMap(Map<String, dynamic> data, String id) {
    return OrderItem(
      productId: data['productId'] ?? '',
      name: data['name'] ?? '',
      quantity: data['quantity'] ?? 0,
      unitPrice:data['unitPrice']?? 0,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      "name":name,
      "productId":productId,
      "quantity": quantity,
      "unitPrice": unitPrice,
    };
  }
   
}
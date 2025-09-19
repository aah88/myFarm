import 'package:cloud_firestore/cloud_firestore.dart';

import 'cart_model.dart';
import 'order_status.dart';

class Order {
  final String id;
  final List<OrderItem> items;
  final String userId;
  final String farmerId;
  final String paymentMeanId;
  final String deliveryMeanId;
  final OrderStatus status;
  Timestamp startDate;

  Order({
    required this.id,
    required this.items,
    required this.userId,
    required this.farmerId,
    required this.paymentMeanId,
    required this.deliveryMeanId,
    required this.status,
    required this.startDate,
  });

  factory Order.fromMap(Map<String, dynamic> data, String id) {
    var itemsList = <OrderItem>[];
    if (data['items'] != null) {
      itemsList =
          List<Map<String, dynamic>>.from(
            data['items'],
          ).map((item) => OrderItem.fromMap(item)).toList();
    }
    return Order(
      id: id,
      items: itemsList,
      userId: data['userId'] ?? '',
      farmerId: data['farmerId'] ?? '',
      paymentMeanId: data['paymentMeanId'] ?? '',
      deliveryMeanId: data['deliveryMeanId'] ?? '',
      startDate: data['startDate'] ?? FieldValue.serverTimestamp(),
      status: OrderStatus.values.firstWhere(
        (s) => s.toString() == 'OrderStatus.${data['status']}',
        orElse: () => OrderStatus.pending,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'items': items.map((item) => item.toMap()).toList(),
      'userId': userId,
      'farmerId': farmerId,
      'paymentMeanId': paymentMeanId,
      'deliveryMeanId': deliveryMeanId,
      'status': status.name,
      'startDate': startDate,
    };
  }

  factory Order.userOrder(String userId, String farmerId) {
    return Order(
      id: '',
      items: [],
      userId: userId,
      farmerId: farmerId,
      paymentMeanId: '',
      deliveryMeanId: '',
      status: OrderStatus.pending,
      startDate: Timestamp.now(),
    );
  }
  factory Order.empty() {
    return Order(
      id: '',
      items: [],
      userId: '',
      farmerId: '',
      paymentMeanId: '',
      deliveryMeanId: '',
      status: OrderStatus.pending,
      startDate: Timestamp.now(),
    );
  }

  Order copyWith({
    String? id,
    List<OrderItem>? items,
    String? userId,
    String? farmerId,
    String? paymentMeanId,
    String? deliveryMeanId,
    OrderStatus? status,
    Timestamp? startDate,
  }) {
    return Order(
      id: id ?? '',
      items: items ?? this.items,
      userId: userId ?? this.userId,
      farmerId: farmerId ?? this.farmerId,
      paymentMeanId: paymentMeanId ?? this.paymentMeanId,
      deliveryMeanId: deliveryMeanId ?? this.deliveryMeanId,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
    );
  }
}

class OrderItem {
  final String listingId;
  final int qty;

  OrderItem({required this.listingId, required this.qty});

  factory OrderItem.fromMap(Map<String, dynamic> data) {
    return OrderItem(
      listingId: data['listingId'] ?? '',
      qty: (data['qty'] ?? 0).toInt(),
    );
  }

  factory OrderItem.fromCartItem(CartItem cartItem) {
    return OrderItem(listingId: cartItem.listingId, qty: cartItem.qty);
  }

  Map<String, dynamic> toMap() {
    return {"listingId": listingId, "qty": qty};
  }

  factory OrderItem.empty() {
    return OrderItem(listingId: '', qty: 0);
  }
}

//Extension
extension CartToOrder on Cart {
  List<Order> toOrder({
    required String paymentMeanId,
    required String deliveryMeanId,
    required OrderStatus status,
    required userId,
  }) {
    final Map<String, List<CartItem>> groupedByFarmer = {};
    final List<Order> orders = [];
    for (final item in items) {
      groupedByFarmer.putIfAbsent(item.farmerId, () => []).add(item);
    }
    groupedByFarmer.forEach((farmerId, cartItems) {
      orders.add(
        Order(
          id: '',
          items:
              cartItems
                  .map((cartItem) => OrderItem.fromCartItem(cartItem))
                  .toList(),
          userId: userId,
          farmerId: farmerId,
          paymentMeanId: paymentMeanId,
          deliveryMeanId: deliveryMeanId,
          status: status,
          startDate: Timestamp.now(),
        ),
      );
    });
    return orders;
  }
}

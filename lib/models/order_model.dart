import 'package:cloud_firestore/cloud_firestore.dart';

import 'cart_model.dart';
import 'order_status.dart';

class Order {
  final String id;
  final List<OrderItem> items;
  final String userId;
  final String sellerId;
  final String paymentMeanId;
  final String deliveryMeanId;
  final OrderStatus status;
  Timestamp startDate;

  Order({
    required this.id,
    required this.items,
    required this.userId,
    required this.sellerId,
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
      sellerId: data['sellerId'] ?? '',
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
      'sellerId': sellerId,
      'paymentMeanId': paymentMeanId,
      'deliveryMeanId': deliveryMeanId,
      'status': status.name,
      'startDate': startDate,
    };
  }

  factory Order.userOrder(String userId, String sellerId) {
    return Order(
      id: '',
      items: [],
      userId: userId,
      sellerId: sellerId,
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
      sellerId: '',
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
    String? sellerId,
    String? paymentMeanId,
    String? deliveryMeanId,
    OrderStatus? status,
    Timestamp? startDate,
  }) {
    return Order(
      id: id ?? '',
      items: items ?? this.items,
      userId: userId ?? this.userId,
      sellerId: sellerId ?? this.sellerId,
      paymentMeanId: paymentMeanId ?? this.paymentMeanId,
      deliveryMeanId: deliveryMeanId ?? this.deliveryMeanId,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
    );
  }

  double totalPrice() {
    double total = 0;
    for (var item in items) {
      total += (item.price * item.qty);
    }
    return total;
  }
}

class OrderItem {
  final String listingId;
  final int qty;
  final double price;

  OrderItem({required this.listingId, required this.price, required this.qty});

  factory OrderItem.fromMap(Map<String, dynamic> data) {
    return OrderItem(
      listingId: data['listingId'] ?? '',
      qty: (data['qty'] ?? 0).toInt(),
      price: data['price'] ?? 0.0,
    );
  }

  factory OrderItem.fromCartItem(CartItem cartItem) {
    return OrderItem(
      listingId: cartItem.listingId,
      price: cartItem.price,
      qty: cartItem.qty,
    );
  }

  Map<String, dynamic> toMap() {
    return {"listingId": listingId, "price": price, "qty": qty};
  }

  factory OrderItem.empty() {
    return OrderItem(listingId: '', price: 0.0, qty: 0);
  }
  double totalItemPrice() {
    return qty * price;
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
    //The order as placed by the user can include many lissting, each belong a farmer,
    //the System will internally split this order into 2, one for each farmer.
    //the time of placing the order will be the same for all and it will be used to
    //
    final Map<String, List<CartItem>> groupedBySeller = {};
    final List<Order> orders = [];
    for (final item in items) {
      groupedBySeller.putIfAbsent(item.sellerId, () => []).add(item);
    }
    final timeOfOrder = Timestamp.now();
    groupedBySeller.forEach((sellerId, cartItems) {
      orders.add(
        Order(
          id: '',
          items:
              cartItems
                  .map((cartItem) => OrderItem.fromCartItem(cartItem))
                  .toList(),
          userId: userId,
          sellerId: sellerId,
          paymentMeanId: paymentMeanId,
          deliveryMeanId: deliveryMeanId,
          status: status,
          startDate: timeOfOrder,
        ),
      );
    });
    return orders;
  }
}

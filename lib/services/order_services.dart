import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import '../../models/cart_model.dart';
import '../../models/order_status.dart';
import '../../models/order_model.dart';

class OrderService {
  final _db = FirebaseFirestore.instance;

  Future<void> createOrder(
    Cart cart,
    String selectedDelivery,
    String selectedPayment,
    OrderStatus status,
    String userId,
  ) async {
    // convert:
    final orders = cart.toOrder(
      paymentMeanId: selectedPayment,
      deliveryMeanId: selectedDelivery,
      status: status,
      userId: userId,
    );
    for (final order in orders) {
      await _db.collection('order').add(order.toMap());
    }
  }

  Future<Order?> getOrderById(String id) async {
    final doc = await _db.collection('order').doc(id).get();
    if (doc.exists) {
      return Order.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _db.collection('order').doc(orderId).update({'status': status.name});
  }

  Future<List<Order>> getAllOrders() async {
    final snapshot = await _db.collection('order').get();
    return snapshot.docs
        .map((doc) => Order.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<List<Order>> getOnlyNewFarmerSellOrders(String sellerId) async {
    final snapshot =
        await _db
            .collection('order')
            .where('sellerId', isEqualTo: sellerId)
            .get();

    return snapshot.docs
        .map((doc) => Order.fromMap(doc.data(), doc.id))
        .where(
          (order) =>
              order.status != OrderStatus.completed &&
              order.status != OrderStatus.failed &&
              order.status != OrderStatus.cancelled,
        )
        .toList();
  }

  Future<List<Order>> getPendingSellOrders(String sellerId) async {
    final snapshot =
        await _db
            .collection('order')
            .where('sellerId', isEqualTo: sellerId)
            .get();

    return snapshot.docs
        .map((doc) => Order.fromMap(doc.data(), doc.id))
        .where((order) => order.status == OrderStatus.pending)
        .toList();
  }

  Future<List<Order>> getAllFarmerSellOrders(String sellerId) async {
    final snapshot =
        await _db
            .collection('order')
            .where('sellerId', isEqualTo: sellerId)
            .get();
    return snapshot.docs
        .map((doc) => Order.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<List<Order>> getAllUserPurchaseOrders(String userId) async {
    final snapshot =
        await _db.collection('order').where('userId', isEqualTo: userId).get();
    return snapshot.docs
        .map((doc) => Order.fromMap(doc.data(), doc.id))
        .toList();
  }
}

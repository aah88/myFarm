import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import '../../models/cart_model.dart';

class CartService {
  final _db = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getCartByUserId(String userId) async {
    try {
      DocumentSnapshot doc = await _db.collection("cart").doc(userId).get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      } else {
        print("No cart found for this user");
        return null;
      }
    } catch (e) {
      print("Error fetching cart: $e");
      return null;
    }
  }

  Future<void> addCart(Cart cart) async {
    await _db.collection('cart').add(cart.toMap());
  }
}

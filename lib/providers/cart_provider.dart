import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/models/full_listing.dart';
import '../../models/cart_model.dart';
import '../../models/listing_model.dart'; // <-- adjust to your actual path


class CartProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Cart _cart = Cart.empty();
  Cart get cart => _cart;

  /// Load cart from Firestore by userId
  Future<void> loadCart(String userId) async {
    try {
      DocumentSnapshot doc = await _db.collection("cart").doc(userId).get();
      if (doc.exists) {
        _cart = Cart.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        _cart = Cart.userCart(userId);
        await saveCart(); // create empty cart in Firestore
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading cart: $e");
    }
  }

  /// Add item to cart
  void addItem(CartItem item) {
    List<CartItem> updatedItems = List.from(_cart.items);

    int index = updatedItems.indexWhere((i) => i.listingId == item.listingId);

    if (index >= 0) {
      // Update quantity if already in cart
      updatedItems[index] = CartItem(
        listingId: updatedItems[index].listingId,
        qty: updatedItems[index].qty + item.qty,
      );
    } else {
      updatedItems.add(item);
    }

    _cart = _cart.copyWith(items: updatedItems);
    notifyListeners();
    saveCart();
  }

  /// Remove item from cart
  void removeItem(String listingId) {
    List<CartItem> updatedItems =
        _cart.items.where((item) => item.listingId != listingId).toList();

    _cart = _cart.copyWith(items: updatedItems);
    notifyListeners();
    saveCart();
  }

  /// Clear cart
  void clearCart() {
    _cart = _cart.copyWith(items: []);
    notifyListeners();
    saveCart();
  }

  /// Save cart to Firestore
  Future<void> saveCart() async {
    try {
      await _db.collection("cart").doc(_cart.userId).set(_cart.toMap());
    } catch (e) {
      debugPrint("Error saving cart: $e");
    }
  }
  void updateQty(String listingId, int qty) {
  final index = _cart.items.indexWhere((item) => item.listingId == listingId);
  if (index != -1) {
    _cart.items[index] = CartItem(listingId: listingId, qty: qty);
    notifyListeners();
  }
}

double totalPrice(Map<String, FullListing> listingMap) {
  double total = 0;
  for (var item in _cart.items) {
    final listing = listingMap[item.listingId];
    if (listing != null) {
      total += (listing.price * item.qty);
    }
  }
  return total;
}
}


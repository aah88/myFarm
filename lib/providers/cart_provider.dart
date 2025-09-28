import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../models/cart_model.dart';
import '../models/listing_model.dart';

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

  /// Add item to cart -> returns true if added, false otherwise
  Future<bool> addItem(CartItem item) async {
    try {
      // If you only want to check the *extra* qty being added (delta):
      final ok = await canAddToCart(
        listingId: item.listingId,
        desiredQty: item.qty,
      );

      if (!ok) {
        return false; // ❌ not enough stock
      }

      // proceed with local cart update
      final List<CartItem> updatedItems = List<CartItem>.from(_cart.items);
      final int index = updatedItems.indexWhere(
        (i) => i.listingId == item.listingId,
      );

      if (index >= 0) {
        // Merge quantities
        final current = updatedItems[index];
        updatedItems[index] = CartItem(
          listingId: current.listingId,
          sellerId: current.sellerId,
          price: current.price,
          qty: current.qty + item.qty,
        );
      } else {
        updatedItems.add(item);
      }

      _cart = _cart.copyWith(items: updatedItems);
      notifyListeners();
      await saveCart(); // if saveCart is async; otherwise remove await

      return true; // ✅ added successfully
    } catch (e) {
      // Optionally log the error
      return false; // ❌ something went wrong
    }
  }

  Future<bool> canAddToCart({
    required String listingId,
    required int desiredQty,
  }) async {
    if (desiredQty <= 0) return false;

    final ref = _db.collection('listing').doc(listingId);
    final snap = await ref.get();
    if (!snap.exists) return false;

    final data = snap.data() as Map<String, dynamic>;

    final bool active = (data['active'] as bool?) ?? true;
    final int availableQty = (data['qty'] as int?) ?? 0;
    final int minimumQty = (data['minimumQty'] as int?) ?? 0;

    if (!active) return false;

    // We require availableQty >= desired and also that the remaining qty
    // would not violate your minimumQty policy (if you enforce it that way).
    if (desiredQty < minimumQty) return false;
    final int remaining = availableQty - desiredQty;
    if (availableQty < desiredQty) return false;
    if (remaining < 0) return false;
    return true;
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

  Future<bool> updateQty(
    String listingId,
    String sellerId,
    double price,
    int qty,
  ) async {
    try {
      // If you only want to check the *extra* qty being added (delta):
      final ok = await canAddToCart(listingId: listingId, desiredQty: qty);

      if (!ok) {
        return false; // ❌ not enough stock
      }
      final index = _cart.items.indexWhere(
        (item) => item.listingId == listingId,
      );
      if (index != -1) {
        _cart.items[index] = CartItem(
          listingId: listingId,
          sellerId: sellerId,
          price: price,
          qty: qty,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      // Optionally log the error
      return false; // ❌ something went wrong
    }
  }

  double totalPrice(Map<String, Listing> listingMap) {
    double total = 0;
    for (var item in _cart.items) {
      final listing = listingMap[item.listingId];
      if (listing != null) {
        total += (listing.price * item.qty);
      }
    }
    return total;
  }

  double itemTotal(String listingId, int qty, Map<String, Listing> listingMap) {
    final listing = listingMap[listingId];
    if (listing == null) return 0;
    return listing.price * qty;
  }
}

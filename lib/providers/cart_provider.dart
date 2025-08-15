import 'package:flutter/foundation.dart';
import '../../models/cart_model.dart';
import '../../models/listing_model.dart' show Listing; // <-- adjust to your actual path

class CartProvider with ChangeNotifier {
  Cart _cart = Cart.empty();

  Cart get cart => _cart;

  List<CartItem> get items => _cart.items;

  int get totalItems => _cart.items.fold(0, (sum, item) => sum + item.qty);

  void setCart(Cart cart) {
    _cart = cart;
    notifyListeners();
  }

  void addItem(String listingId, {int qty = 1}) {
    final index = _cart.items.indexWhere((item) => item.listingId == listingId);

    if (index >= 0) {
      _cart.items[index] = CartItem(
        listingId: _cart.items[index].listingId,
        qty: _cart.items[index].qty + qty,
      );
    } else {
      _cart.items.add(CartItem(listingId: listingId, qty: qty));
    }
    notifyListeners();
  }

  void removeItem(String listingId) {
    _cart.items.removeWhere((item) => item.listingId == listingId);
    notifyListeners();
  }

  void updateQuantity(String listingId, int qty) {
    final index = _cart.items.indexWhere((item) => item.listingId == listingId);
    if (index >= 0) {
      _cart.items[index] = CartItem(
        listingId: _cart.items[index].listingId,
        qty: qty,
      );
      notifyListeners();
    }
  }

  void clearCart() {
    _cart = Cart.empty();
    notifyListeners();
  }

  void updateQty(String listingId, int qty) {
  final index = _cart.items.indexWhere((item) => item.listingId == listingId);
  if (index != -1) {
    _cart.items[index] = CartItem(listingId: listingId, qty: qty);
    notifyListeners();
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
}

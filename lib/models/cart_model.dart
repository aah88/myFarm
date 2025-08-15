class Cart {
  final List<CartItem> items;

  Cart({required this.items});

  factory Cart.fromMap(Map<String, dynamic> data) {
    var itemsList = <CartItem>[];
    if (data['items'] != null) {
      itemsList = List<Map<String, dynamic>>.from(data['items'])
          .map((item) => CartItem.fromMap(item))
          .toList();
    }
    return Cart(items: itemsList);
  }

  Map<String, dynamic> toMap() {
    return {
      'items': items.map((item) => item.toMap()).toList(),
    };
  }

  factory Cart.empty() {
    return Cart(items: []);
  }
}

class CartItem {
  final String listingId;
  final int qty;

  CartItem({required this.listingId, required this.qty});

  factory CartItem.fromMap(Map<String, dynamic> data) {
    return CartItem(
      listingId: data['listingId'] ?? '',
      qty: (data['qty'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "listingId": listingId,
      "qty": qty,
    };
  }

  factory CartItem.empty() {
    return CartItem(listingId: '', qty: 0);
  }
}
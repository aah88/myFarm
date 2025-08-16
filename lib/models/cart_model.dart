class Cart {
  final List<CartItem> items;
  final String userId;
  
  Cart({required this.items, required this.userId});

  factory Cart.fromMap(Map<String, dynamic> data) {
    var itemsList = <CartItem>[];
    if (data['items'] != null) {
      itemsList = List<Map<String, dynamic>>.from(data['items'])
          .map((item) => CartItem.fromMap(item))
          .toList();
    }
    return Cart(items: itemsList, userId: data['userId'] ?? '');
  }

  Map<String, dynamic> toMap() {
    return {
      'items': items.map((item) => item.toMap()).toList(),
      'userId': userId
    };
  }

  factory Cart.userCart(String userId) {
    return Cart(items: [], userId: userId);
  }
    factory Cart.empty() {
    return Cart(items: [], userId: '');
  }

   Cart copyWith({
    List<CartItem>? items,
    String? userId,
 
  }) {
    return Cart(
      items: items??this.items,
      userId: userId ?? this.userId,

    );
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
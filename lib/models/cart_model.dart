

class Cart {
  final List<CartItem> items;

  Cart({required this.items,
    });

  factory Cart.fromMap(Map<String, dynamic> data, String id) {
    return Cart(
      items: data['items'] ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'items': items,
    };
  }
}
class CartItem{
  final String productId;
  final int quantity;
  final int unitPrice;

  CartItem({
    required this.productId,
    required this.quantity,
    required this.unitPrice
    });

  factory CartItem.fromMap(Map<String, dynamic> data, String id) {
    return CartItem(
      productId: data['productId'] ?? '',
      quantity: data['quantity'] ?? 0,
      unitPrice:data['unitPrice']?? 0,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      "productId":productId,
      "quantity": quantity,
      "unitPrice": unitPrice,
    };
  }
   
}

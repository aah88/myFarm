import 'package:cloud_firestore/cloud_firestore.dart';

class Listing {
  String id;
  String sellerId;
  String sellerName;
  String categoryId;
  String productId;
  String productName;
  String productImageUrl;
  String unit;
  int qty;
  double price;
  double rating;
  int minimumQty;
  bool active;
  Timestamp startDate;

  Listing({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    required this.categoryId,
    required this.productId,
    required this.productName,
    required this.productImageUrl,
    required this.unit,
    required this.qty,
    required this.active,
    required this.price,
    required this.rating,
    required this.minimumQty,
    required this.startDate,
  });

  factory Listing.fromMap(Map<String, dynamic> data, String id) {
    return Listing(
      id: id,
      sellerId: data['sellerId'] ?? '',
      sellerName: data['sellerName'] ?? '',
      categoryId: data['categoryId'] ?? '',
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      productImageUrl:
          data['productImageUrl'] ?? 'lib/assets/images/placeholder.webp',
      unit: data['unit'] ?? '',
      qty: data['qty'] ?? 0,
      active: data['qty'] > 0 ?? false,
      price: data['price'] ?? 0.0,
      rating: data['rating'] ?? 0.0,
      minimumQty: data['qty'] ?? 0,
      startDate: data['startDate'] ?? FieldValue.serverTimestamp(),
    );
  }

  factory Listing.empty() {
    return Listing(
      id: '',
      categoryId: '',
      productId: '',
      productName: '',
      productImageUrl: '',
      sellerId: '',
      sellerName: '',
      unit: '',
      qty: 0,
      active: false,
      price: 0.0,
      rating: 0,
      minimumQty: 0,
      startDate: Timestamp.now(),
    );
  }

  /// CopyWith method for updating only some fields
  Listing copyWith({
    String? id,
    String? sellerId,
    String? sellerName,
    String? categoryId,
    String? productId,
    String? productName,
    String? productImageUrl,
    String? unit,
    int? qty,
    bool? active,
    double? price,
    double? rating,
    int? minimumQty,
    Timestamp? startDate,
  }) {
    return Listing(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      categoryId: categoryId ?? this.categoryId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImageUrl: productImageUrl ?? this.productImageUrl,
      unit: unit ?? this.unit,
      qty: qty ?? this.qty,
      active: active ?? this.active,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      minimumQty: minimumQty ?? this.minimumQty,
      startDate: startDate ?? this.startDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'categoryId': categoryId,
      'productId': productId,
      'productName': productName,
      'productImageUrl': productImageUrl,
      'unit': unit,
      'qty': qty,
      'price': price,
      'rating': rating,
      'minimumQty': minimumQty,
      'startDate': startDate,
    };
  }
}

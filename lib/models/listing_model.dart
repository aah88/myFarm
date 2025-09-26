import 'package:cloud_firestore/cloud_firestore.dart';

class Listing {
  String id;
  String userId;
  String categoryId;
  String productId;
  String unit;
  int qty;
  double price;
  double rating;
  int minimumQty;
  bool active;
  Timestamp startDate;

  Listing({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.productId,
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
      userId: data['userId'] ?? '',
      categoryId: data['categoryId'] ?? '',
      productId: data['productId'] ?? '',
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
      userId: '',
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
    String? userId,
    String? categoryId,
    String? productId,
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
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      productId: productId ?? this.productId,
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
      'userId': userId,
      'categoryId': categoryId,
      'productId': productId,
      'unit': unit,
      'qty': qty,
      'price': price,
      'rating': rating,
      'minimumQty': minimumQty,
      'startDate': startDate,
    };
  }
}

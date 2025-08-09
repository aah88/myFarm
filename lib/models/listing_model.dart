import 'package:cloud_firestore/cloud_firestore.dart';

class Listing {
   String id;
   String farmerId;
   String categoryId; 
   String productId; 
   String unit; 
   String qty; 
   String price; 
   Timestamp startDate; 

  Listing({required this.id,
    required this.categoryId,
    required this.productId,
    required this.farmerId,
    required this.unit,
    required this.qty,
    required this.price,
    required this.startDate,
    });

  factory Listing.fromMap(Map<String, dynamic> data, String id) {
    return Listing(
      id: id,
      farmerId: data['farmerId'] ?? '',
      categoryId: data['categoryId'] ?? '',
      productId: data['productId']?? '',
      unit: data['unit']?? '',
      qty: data['qty']?? '',
      price: data['price']?? '',
      startDate: data['startDate']?? FieldValue.serverTimestamp(),
    );
  }

 factory Listing.empty() {
    return Listing(
      id: '',
      categoryId: '',
      productId: '',
      farmerId: '',
      unit: '',
      qty: '',
      price: '',
      startDate: Timestamp.now(),
    );
  }
  /// CopyWith method for updating only some fields
  Listing copyWith({
    String? id,
    String? farmerId,
    String? categoryId,
    String? productId,
    String? unit,
    String? qty,
    String? price,
    Timestamp? startDate,
  }) {
    return Listing(
      id: id ?? this.id,
      farmerId: farmerId ?? this.farmerId,
      categoryId: categoryId ?? this.categoryId,
      productId: productId ?? this.productId,
      unit: unit ?? this.unit,
      qty: qty ?? this.qty,
      price: price ?? this.price,
      startDate: startDate ?? this.startDate,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'farmerId': farmerId,
      'categoryId': categoryId,
      'productId': productId,
      'unit': unit,
      'qty': qty,
      'price': price,
      'startDate': startDate,
    };
  }
}
class FullListing {
  final String id;
  final String userId;
  final String productId;
  final int qty;
  final String farmerName;
  final String unit;
  final double price;
  final double rating;
  final String productName;
  final String productImageUrl;
  final int minimumQty;

  FullListing({
    required this.id,
    required this.unit,
    required this.userId,
    required this.productId,
    required this.qty,
    required this.farmerName,
    required this.price,
    required this.rating,
    required this.productName,
    required this.productImageUrl,
    required this.minimumQty,
  });

  /// Optional: create from Firestore data
  factory FullListing.fromMap(
    Map<String, dynamic> listingData,
    Map<String, dynamic> productData,
    Map<String, dynamic> userData,
    String id,
  ) {
    return FullListing(
      id: id,
      userId: listingData['userId'] ?? '',
      unit: listingData['unit'] ?? '',
      farmerName: userData['name'] ?? '',
      minimumQty: listingData['minimumQty'] ?? 0,
      productId: listingData['productId'] ?? '',
      qty: listingData['qty'] ?? 0,
      price: listingData['price'] ?? 0.0,
      rating: listingData['rating'] ?? 0.0,
      productName: productData['name'] ?? '',
      productImageUrl:
          productData['imageUrl'] ?? 'lib/assets/images/placeholder.webp',
    );
  }

  factory FullListing.empty() {
    return FullListing(
      id: '',
      productId: '',
      farmerName: '',
      userId: '',
      unit: '',
      qty: 0,
      price: 0.0,
      rating: 0,
      minimumQty: 0,
      productName: '',
      productImageUrl: '',
    );
  }
  FullListing copyWith({
    String? id,
    String? userId,
    String? productId,
    int? qty,
    String? farmerName,
    String? unit,
    double? price,
    double? rating,
    String? productName,
    String? productImageUrl,
    int? minimumQty,
  }) {
    return FullListing(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      qty: qty ?? this.qty,
      farmerName: farmerName ?? this.farmerName,
      unit: unit ?? this.unit,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      productName: productName ?? this.productName,
      productImageUrl: productImageUrl ?? this.productImageUrl,
      minimumQty: minimumQty ?? this.minimumQty,
    );
  }
}

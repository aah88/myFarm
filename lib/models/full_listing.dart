class FullListing {
  final String farmerId;
  final String productId;
  final int qty;
  final String price;
  final double rating;
  final String productName;
  final String productImageUrl;

  FullListing({
    required this.farmerId,
    required this.productId,
    required this.qty,
    required this.price,
    required this.rating,
    required this.productName,
    required this.productImageUrl,
  });

  /// Optional: create from Firestore data
  factory FullListing.fromMap(Map<String, dynamic> listingData, Map<String, dynamic> productData) {
    return FullListing(
      farmerId: listingData['farmerId'] ?? '',
      productId: listingData['productId'] ?? '',
      qty: listingData['qty'] ?? 0,
      price: listingData['price'] ?? 0.0,
      rating: listingData['rating']?? 0.0,
      productName: productData['name'] ?? '',
      productImageUrl: productData['imageUrl'] ?? '',
    );
  }
}
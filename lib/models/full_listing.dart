class FullListing {
  final String id;
  final String farmerId;
  final String productId;
  final int qty;
  final String farmerName;
  final String unit;
  final double price;
  final double rating;
  final String productName;
  final String productImageUrl;

  FullListing({
    required this.id,
    required this.unit,
    required this.farmerId,
    required this.productId,
    required this.qty,
    required this.farmerName,
    required this.price,
    required this.rating,
    required this.productName,
    required this.productImageUrl,
  });

  /// Optional: create from Firestore data
  factory FullListing.fromMap(Map<String, dynamic> listingData, Map<String, dynamic> productData, Map<String, dynamic> userData, String id) {
    return FullListing(
      id: id,
      farmerId: listingData['farmerId'] ?? '',
      unit:listingData['unit']??'',
      farmerName: userData['name'] ?? '',
      productId: listingData['productId'] ?? '',
      qty: listingData['qty'] ?? 0,
      price: listingData['price'] ?? 0.0,
      rating: listingData['rating']?? 0.0,
      productName: productData['name'] ?? '',
      productImageUrl: productData['imageUrl'] ?? '',
    );
  }
}
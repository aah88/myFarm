import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/listing_model.dart';
import '../../models/product_model.dart';
import '../../models/category_model.dart';
import '../../models/farmer_model.dart';
import '../../models/full_listing.dart';
import '../../models/user_model.dart';

class FirebaseService {
  final _db = FirebaseFirestore.instance;

  Future<void> addProduct(Product product) async {
    await _db.collection('product').add(product.toMap());
  }

  

  Future<List<Product>> getProducts() async {
    final snapshot = await _db.collection('product').get();
    return snapshot.docs.map((doc) =>
        Product.fromMap(doc.data(), doc.id)).toList();
  }


  Future<List<ProductCategory>> getCategory() async {
    final snapshot = await _db.collection('category').get();
    return snapshot.docs.map((doc) =>
        ProductCategory.fromMap(doc.data(), doc.id)).toList();
  }

  Stream<List<Product>> productStream() {
  return FirebaseFirestore.instance
    .collection('products')
    .snapshots()
    .map((snapshot) =>
      snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList()
    );
}
  Stream<List<ProductCategory>> categoryStream() {
  return FirebaseFirestore.instance
    .collection('category')
    .snapshots() 
    .map((snapshot) =>
      snapshot.docs.map((doc) => ProductCategory.fromFirestore(doc)).toList()
    );
}

 Future<void> addCategory(ProductCategory category) async {
    await _db.collection('category').add(category.toMap());
  }


    Future<List<Product>> getProductsByCategory(String categoryId) async {
    final querySnapshot = await _db
        .collection('product')
        .where('category.id', isEqualTo: categoryId)
        //.where('parent_product', isNull: false)
        .get();
    return querySnapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
  }
  Future<List<Product>> getProductsByCategoryName(String categoryName) async {
    final querySnapshot = await _db
        .collection('product')
        .where('category.name', isEqualTo: categoryName)
        //.where('parent_product', isNull: false)
        .get();
    return querySnapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
  }

   Future<List<Product>> getProductsByProductParent(String productParentId) async {
    final querySnapshot = await _db
        .collection('product')
        .where('parent_product', isEqualTo: productParentId)
        .get();
    return querySnapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
  }

   Future<void> addListing(Listing listing) async {
    await _db.collection('listing').add(listing.toMap());
  }

   Future<List<Listing>> getListing() async {
    final snapshot = await _db.collection('listing').get();
    return snapshot.docs.map((doc) =>
        Listing.fromMap(doc.data(), doc.id)).toList();
  }
    Future<List<Farmer>> getFarmer() async {
    final snapshot = await _db.collection('farmer').get();
    return snapshot.docs.map((doc) =>
        Farmer.fromMap(doc.data(), doc.id)).toList();
  }
   Future<void> addFarmer(Farmer farmer) async {
    await _db.collection('farmer').add(farmer.toMap());
  }
  Future<void> addUser(AppUser user) async {
    await _db.collection('user').add(user.toMap());
  }

  Future<List<FullListing>> getFullListings() async {
  final listingSnapshot = await _db.collection('listing').get();

  // Get all product IDs from listings
  final productIds = listingSnapshot.docs
      .map((doc) => doc['productId'] as String)
      .toSet();

  // Fetch all needed products in one go
  final productSnapshot = await _db
      .collection('product')
      .where(FieldPath.documentId, whereIn: productIds.toList())
      .get();

  final productMap = {
    for (var doc in productSnapshot.docs) doc.id: doc.data()
  };

  // Merge listings with product data
  return listingSnapshot.docs.map((listingDoc) {
    final listingData = listingDoc.data();
    final productData = productMap[listingData['productId']] ?? {};

    return FullListing.fromMap(listingData,productData);
  }).toList();
}


}

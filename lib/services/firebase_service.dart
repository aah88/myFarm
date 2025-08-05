import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../models/product_model.dart';
import '../../models/category_model.dart';

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

}

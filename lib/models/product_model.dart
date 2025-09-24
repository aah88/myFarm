import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/category_model.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final ProductCategory category;
  final String? parentProduct; // optional
  final String? imageUrl; // optional

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.parentProduct,
    this.imageUrl,
  });

  factory Product.fromMap(Map<String, dynamic> data, String id) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: ProductCategory.fromMap(data['category'], id),
      parentProduct: data['parent_product'] ?? '', // may be null
      imageUrl: data['imageUrl'] ?? '', // may be null
    );
  }

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: ProductCategory.fromMap(
        data['category'],
        data['category']['id'],
      ),
      parentProduct: data['parent_product'] ?? '', // optional
      imageUrl: data['imageUrl'] ?? '', // optional
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category.toMap(),
      if (parentProduct != null) 'parent_product': parentProduct,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }
}

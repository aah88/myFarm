import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/models/category_model.dart';

class Product {
  final String id;
  final String name;
  final String description; 
  final ProductCategory category;
  final String parentProduct;
  final String imageUrl;

  Product({required this.id,
    required this.name,
    required this.description,
    required this.parentProduct,
    required this.category,
    required this.imageUrl,
    });

  factory Product.fromMap(Map<String, dynamic> data, String id) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      description: data['description']?? '',
      category: ProductCategory.fromMap(data['category'], id),
      parentProduct: data['parent_product']?? '',
      imageUrl:data['imageUrl']?? '',
    );
  }

   factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description']?? '',
      category: ProductCategory.fromMap(data['category'], data['category']['id']),
      parentProduct: data['parent_product']?? '',
      imageUrl:data['imageUrl']?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category.toMap(),
      'parent_product': parentProduct,
      'imageUrl': imageUrl,
    };
  }
}

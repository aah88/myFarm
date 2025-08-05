import 'package:cloud_firestore/cloud_firestore.dart';

class ProductCategory {
  final String id;
  final String name;


  
ProductCategory({required this.id,
    required this.name,
    });

  factory ProductCategory.fromMap(Map<String, dynamic> data, String id) {
    return 
ProductCategory(
      id: id,
      name: data['name'] ?? '',
    );
  }

   factory ProductCategory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductCategory(
      id: doc.id,
      name: data['name'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }
}

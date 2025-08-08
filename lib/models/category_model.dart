import 'package:cloud_firestore/cloud_firestore.dart';

class ProductCategory {
  final String id;
  final String name;
  final String imageUrl;


  
ProductCategory({required this.id,
    required this.name,
    required this.imageUrl,
    });

  factory ProductCategory.fromMap(Map<String, dynamic> data, String id) {
    return 
ProductCategory(
      id: id,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      
    );
  }

   factory ProductCategory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductCategory(
      id: doc.id,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',

    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id':id,
      'name': name,
      'imageUrl':imageUrl
    };
  }
}

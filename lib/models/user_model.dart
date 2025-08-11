import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String name;
  final String email; 
   final String address;
  final String phone;
  final double rating;
  final String profileImage;
  final Timestamp createdAt;

  User({required this.id,
    required this.name,
    required this.email,
    required this.address,
    required this.phone,
    required this.createdAt,
    required this.rating,
    required this.profileImage
    });

  factory User.fromMap(Map<String, dynamic> data, String id) {
    return User(
      id: id,
      name: data['name'] ?? '',
      email: data['email']?? '',
      address: data['address']?? '',
      phone: data['phone']?? '',
      rating: data['rating']??0.0,
      profileImage: data['profileImage']??'',
      createdAt:data['createdAt']?? FieldValue.serverTimestamp(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'address': address,
      'phone': phone,
      'createdAt': createdAt,
      'profileImage': profileImage,
      'rating':rating

    };
  }

   factory User.empty() {
    return User(
      id: '',
      email: '',
      name:'',
      address: '',
      phone: '',
      rating: 0.0,
      profileImage: '',
      createdAt: Timestamp.now(),
    );
  }
}

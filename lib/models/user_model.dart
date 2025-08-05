import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String name;
  final String email; 
   final String address;
  final String phone;
  final Timestamp createdAt;

  User({required this.id,
    required this.name,
    required this.email,
    required this.address,
    required this.phone,
    required this.createdAt
    });

  factory User.fromMap(Map<String, dynamic> data, String id) {
    return User(
      id: id,
      name: data['name'] ?? '',
      email: data['email']?? '',
      address: data['address']?? '',
      phone: data['phone']?? '',
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
    };
  }
}

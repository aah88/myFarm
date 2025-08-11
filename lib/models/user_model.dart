import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String username;
  final String email; 
   final String address;
  final String phone;
  final double rating;
  final String profileImage;
  final DateTime  createdAt;

  AppUser({required this.id,
    required this.username,
    required this.email,
    required this.address,
    required this.phone,
    required this.createdAt,
    required this.rating,
    required this.profileImage
    });

  factory AppUser.fromMap(Map<String, dynamic> data, String id) {
    return AppUser(
      id: id,
      username: data['username'] ?? '',
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
      'username': username,
      'email': email,
      'address': address,
      'phone': phone,
      'createdAt': createdAt,
      'profileImage': profileImage,
      'rating':rating

    };
  }

   factory AppUser.empty() {
    return AppUser(
      id: '',
      email: '',
      username:'',
      address: '',
      phone: '',
      rating: 0.0,
      profileImage: '',
      createdAt: DateTime.now(),
    );
  }
}

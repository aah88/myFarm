import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String name;
  final String username;
  final String email;
  final String address;
  final String phone;
  final double rating;
  final String profileImage;
  final bool isFarmer;
  final DateTime createdAt;

  AppUser({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.address,
    required this.phone,
    required this.createdAt,
    required this.rating,
    required this.isFarmer,
    required this.profileImage,
  });

  factory AppUser.fromMap(Map<String, dynamic> data, String id) {
    return AppUser(
      id: id,
      name: data['name'] ?? '',
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      address: data['address'] ?? '',
      phone: data['phone'] ?? '',
      rating: data['rating'] ?? 0.0,
      profileImage:
          data['profileImage'] ?? 'lib/assets/images/placeholder.webp',
      isFarmer: data['isFarmer'] ?? false,
      createdAt: data['createdAt'].toDate() ?? FieldValue.serverTimestamp(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'username': username,
      'email': email,
      'address': address,
      'phone': phone,
      'createdAt': createdAt,
      'profileImage': profileImage,
      'rating': rating,
      'isFarmer': isFarmer,
    };
  }

  factory AppUser.empty() {
    return AppUser(
      name: '',
      id: '',
      email: '',
      username: '',
      address: '',
      phone: '',
      rating: 0.0,
      isFarmer: false,
      profileImage: '',
      createdAt: DateTime.now(),
    );
  }
}

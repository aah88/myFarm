
import 'package:cloud_firestore/cloud_firestore.dart';

class Farmer {
  final String id;
   String name;
   String email; 
   String location;
   String phone;
   Timestamp createdAt;
   double rating;
   String profileImage;

  Farmer({required this.id,
    required this.name,
    required this.email,
    required this.location,
    required this.phone,
    required this.createdAt,
    required this.rating,
    required this.profileImage
    });

  factory Farmer.fromMap(Map<String, dynamic> data, String id) {
    return Farmer(
      id: id,
      name: data['name'] ?? '',
      email: data['email']?? '',
      location: data['location']?? '',
      phone: data['phone']?? '',
      rating: data['rating']?? 0,
      profileImage: data['profileImage']?? '',
      createdAt:data['createdAt']?? FieldValue.serverTimestamp(),
    );
  }

 factory Farmer.empty() {
    return Farmer(
      id: '',
      email: '',
      name:'',
      location: '',
      phone: '',
      rating: 0.0,
      profileImage: '',
      createdAt: Timestamp.now(),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'location': location,
      'phone': phone,
      'createdAt': createdAt,
      'rating': rating,
      'profileImage':profileImage

    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String?> signUp({
    required String name,
    required String username,
    required String email,
    required String password,
    required String address,
    required String phone,
    required String profileImage,
  }) async {
    try {
      // Check if username exists
      var usernameCheck = await _db
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (usernameCheck.docs.isNotEmpty) {
        return 'اسم المستخدم موجود بالفعل';
      }

      // Create Firebase Auth user
      UserCredential userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCred.user!.sendEmailVerification();

      // Build AppUser object
      final newUser = AppUser(
        id: userCred.user!.uid,
        name: name,
        username: username,
        email: email,
        address: address,
        phone: phone,
        createdAt: DateTime.now(),
        rating: 0.0,
        profileImage: profileImage,
      );

      // Save to Firestore
      await _db.collection('users').doc(newUser.id).set(newUser.toMap());

      return null; // success
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'البريد الإلكتروني مستخدم بالفعل';
      } else if (e.code == 'weak-password') {
        return 'كلمة المرور ضعيفة جداً';
      } else {
        return e.message;
      }
    } catch (e) {
      return e.toString();
    }
  }
}

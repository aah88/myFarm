import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import '../../models/user_model.dart';

class UserService {
  final _db = FirebaseFirestore.instance;

  Future<AppUser?> getUserById(String userId) async {
    try {
      DocumentSnapshot doc = await _db.collection("users").doc(userId).get();

      if (doc.exists) {
        var data = doc.data() as Map<String, dynamic>;
        return AppUser.fromMap(data, userId);
      } else {
        print("User not found");
        return null;
      }
    } catch (e) {
      print("Error getting user: $e");
      return null;
    }
  }

  Future<void> addUser(AppUser user) async {
    await _db.collection('user').add(user.toMap());
  }
}

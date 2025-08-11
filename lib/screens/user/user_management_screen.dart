import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/firebase_service.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _profileImageController = TextEditingController();


  @override
  void initState() {
    super.initState();
  }

  void _addUser() async {
    if (_nameController.text.isNotEmpty) {
      
      final newUser = AppUser(
        id: '',
        username: _nameController.text,
        email:_emailController.text,
        address: _addressController.text,
        phone: _phoneController.text,
        rating: 0.0,
        profileImage: _profileImageController.text,
        createdAt: DateTime.now()
      );
      await _firebaseService.addUser(newUser);

      _nameController.clear();
      _emailController.clear();
      _addressController.clear();
      _phoneController.clear();
      _profileImageController.clear();
      
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('انشاء حساب مستخدم')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'اسم المستخدم'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'ايميل'),
            ),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'العنوان'),
              keyboardType: TextInputType.url,
            ),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'تلفون'),
              keyboardType: TextInputType.url,
            ),
            TextField(
              controller: _profileImageController,
              decoration: const InputDecoration(labelText: 'صورة'),
              keyboardType: TextInputType.url,
            ),

            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addUser,
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }
}

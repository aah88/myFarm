import 'package:flutter/material.dart';
import '../../models/farmer_model.dart';
import '../../services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//TODO löschen Ahmad
class FarmerManagementScreen extends StatefulWidget {
  const FarmerManagementScreen({super.key});

  @override
  State<FarmerManagementScreen> createState() => _FarmerManagementScreenState();
}

class _FarmerManagementScreenState extends State<FarmerManagementScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _profileImageController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void _addFarmer() async {
    if (_nameController.text.isNotEmpty) {
      
      final newFarmer = Farmer(
        id: '',
        name: _nameController.text,
        email:_emailController.text,
        location: _locationController.text,
        phone: _phoneController.text,
        rating: 0.0,
        profileImage: _profileImageController.text,
        createdAt: Timestamp.now()
      );
      await _firebaseService.addFarmer(newFarmer);

      _nameController.clear();
      _emailController.clear();
      _locationController.clear();
      _phoneController.clear();
      _profileImageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('انشاء حساب مزارع')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'اسم المزارع'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'ايميل'),
            ),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'الموقع'),
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
              onPressed: _addFarmer,
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }
}

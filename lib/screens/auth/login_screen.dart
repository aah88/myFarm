import 'package:flutter/material.dart';
import '../profile/farmer_profile_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل الدخول')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('أدخل رقم الهاتف لتسجيل الدخول'),
            const SizedBox(height: 20),
            const TextField(decoration: InputDecoration(labelText: 'رقم الهاتف')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FarmerProfileScreen())),
              child: const Text('تسجيل الدخول (تمثيلي)'),
            ),
          ],
        ),
      ),
    );
  }
}

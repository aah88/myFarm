import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/home/home_screen_farmer.dart';
import 'package:flutter_application_1/screens/product/product_management_screen.dart';
import 'package:flutter_application_1/screens/category/category_management_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/firebase_service.dart';
import '../auth/validation_per_phone.dart';


class HomeScreenUser extends StatefulWidget {
  const HomeScreenUser({super.key});

  @override
  State<HomeScreenUser> createState() => _HomeScreenUserState();
}

class _HomeScreenUserState extends State<HomeScreenUser> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
void initState() {
  super.initState();

  Future.microtask(() {
    if (!mounted) return; // ✅ guard against context after dispose

    final userProvider = context.read<UserProvider>();
    userProvider.setUserId('fPFgIzsfSbMbiftLFJvaIQx14x42');

    final cartProvider = context.read<CartProvider>();
    cartProvider.loadCart('fPFgIzsfSbMbiftLFJvaIQx14x42');
  });
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الرئيسية')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) =>  PhoneAuthPage())),
              child: const Text('تسجيل الدخول'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) =>  HomeScreenFarmer())),
              child: const Text('استعراض كزائر'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductManagementScreen())),
              child: const Text('Add Product'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryManagementScreen())),
              child: const Text('Add Category'),
            ),
            const SizedBox(height: 20),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

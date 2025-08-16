import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/bottom_nav.dart';

class ConsumerProfileScreen extends StatelessWidget {
  const ConsumerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('حساب المستهلك')),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.person),
            title: Text('الاسم: محمد'),
          ),
          ListTile(
            leading: Icon(Icons.location_on),
            title: Text('المنطقة: دمشق'),
          ),
          ListTile(
            leading: Icon(Icons.shopping_cart),
            title: Text('طلباتي'),
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('تسجيل الخروج'),
          ),
        ],
      ),
      // ✅ BottomNav بدون تفعيل أي تبويب
      bottomNavigationBar: const BottomNav(current: null),
    );
  }
}

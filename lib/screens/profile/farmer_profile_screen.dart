import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/bottom_nav.dart';
import '../order/order_list_screen.dart';
import '../product/product_management_screen.dart';

class FarmerProfileScreen extends StatelessWidget {
  const FarmerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('حساب المزارع')),
      body: Column(
        children: [
          const ListTile(
            leading: Icon(Icons.person),
            title: Text('الاسم: أحمد'),
          ),
          const ListTile(
            leading: Icon(Icons.location_on),
            title: Text('ريف دمشق'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderListScreen())),
            child: const Text('عرض الطلبات'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductManagementScreen())),
            child: const Text('إدارة المنتجات'),
          ),
        ],
      ),
      // ✅ BottomNav بدون تفعيل أي تبويب
      bottomNavigationBar: const BottomNav(current: null),
    );
  }
}

import 'package:flutter/material.dart';

class OrderListScreen extends StatelessWidget {
  const OrderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = [
      {'customer': 'سارة', 'item': 'تفاح', 'qty': 4},
      {'customer': 'خالد', 'item': 'بطاطا', 'qty': 2},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('الطلبات')),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: Text('${order['item']} × ${order['qty']}'),
            subtitle: Text('العميل: ${order['customer']}'),
          );
        },
      ),
    );
  }
}

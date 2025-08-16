import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/order/order_details_screen.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/bottom_nav.dart';

class OrderListScreen extends StatelessWidget {
  const OrderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = [
      {'customer': 'سارة', 'item': 'تفاح',  'qty': 4},
      {'customer': 'خالد', 'item': 'بطاطا', 'qty': 2},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('الطلبات')),
      body: ListView.separated(
        itemCount: orders.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final order = orders[index];
          return ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: Text('${order['item']} × ${order['qty']}'),
            subtitle: Text('العميل: ${order['customer']}'),
            trailing: const Icon(Icons.chevron_left), // للسهم RTL
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OrderDetailsScreen(order: order),
                ),
              );
            },
          );
        },
      ),
    );

  }
}

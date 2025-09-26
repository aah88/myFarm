import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/user_provider.dart';
import 'package:flutter_application_1/widgets/app_scaffold.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_1/widgets/bottom_nav.dart';

import '../../providers/cart_provider.dart';
import '../../services/order_services.dart';
import '../../models/order_model.dart';

class AllNewOrdersFarmerScreen extends StatefulWidget {
  const AllNewOrdersFarmerScreen({super.key});

  @override
  State<AllNewOrdersFarmerScreen> createState() =>
      _AllNewOrdersFarmerScreenState();
}

class _AllNewOrdersFarmerScreenState extends State<AllNewOrdersFarmerScreen> {
  final OrderService _orderService = OrderService();
  final List<String> _expandedOrderIds = [];

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final cart = cartProvider.cart;
    return AppScaffold(
      currentTab: null,
      cartPadgeCount: cart.items.length,
      appBar: AppBar(title: const Text("📦 All Orders")),
      body: FutureBuilder<List<Order>>(
        future: _orderService.getOnlyNewFarmerSellOrders(
          context.read<UserProvider>().userId!,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No orders found"));
          }

          final orders = snapshot.data!;

          return SingleChildScrollView(
            child: ExpansionPanelList(
              expansionCallback: (index, _) {
                setState(() {
                  final orderId = orders[index].id;
                  if (_expandedOrderIds.contains(orderId)) {
                    _expandedOrderIds.remove(orderId);
                  } else {
                    _expandedOrderIds.add(orderId);
                  }
                });
              },
              children:
                  orders.map((order) {
                    final isExpanded = _expandedOrderIds.contains(order.id);
                    return ExpansionPanel(
                      canTapOnHeader: true,
                      isExpanded: isExpanded,
                      headerBuilder: (context, isExpanded) {
                        return ListTile(
                          title: Text("Order #${order.id}"),
                          subtitle: Text(
                            "الإجمالي: ${order.totalPrice()} ل.س • حالة: ${order.status.name} • تاريخ: ${order.startDate.toDate().toString().split(' ').first}",
                          ),
                        );
                      },
                      body: Column(
                        children:
                            order.items.map((item) {
                              return ListTile(
                                leading: const Icon(Icons.shopping_cart),
                                title: Text(item.listingId),
                                subtitle: Text("الكمية: ${item.qty}"),
                                trailing: Text(
                                  "الإجمالي: ${item.totalItemPrice()} ل.س",
                                ),
                              );
                            }).toList(),
                      ),
                    );
                  }).toList(),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/user_provider.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_1/widgets/bottom_nav.dart';

import '../../services/order_services.dart';
import '../../models/order_model.dart'; // ✅ الكارت الجديد

class AllOrdersFarmerScreen extends StatefulWidget {
  const AllOrdersFarmerScreen({super.key});

  @override
  State<AllOrdersFarmerScreen> createState() => _AllOrdersFarmerScreenState();
}

class _AllOrdersFarmerScreenState extends State<AllOrdersFarmerScreen> {
  final OrderService _orderService =
      OrderService(); // wrapper for getAllOrders()
  final List<String> _expandedOrderIds = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("📦 All Orders")),
      body: FutureBuilder<List<Order>>(
        future: _orderService.getAllFarmerSellOrders(
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
              expansionCallback: (index, isExpanded) {
                setState(() {
                  final orderId = orders[index].id;
                  if (isExpanded) {
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
                            "${order.items.length} items • Status: ${order.status.name} • Date: ${order.startDate.toDate().toString().split(' ').first}",
                          ),
                        );
                      },
                      body: Column(
                        children:
                            order.items.map((item) {
                              return ListTile(
                                leading: const Icon(Icons.shopping_cart),
                                title: Text(item.listingId),
                                subtitle: Text("x${item.qty}"),
                                trailing: Text(
                                  "22", //"$${item.price.toStringAsFixed(2)}",
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
      bottomNavigationBar: const BottomNav(current: null),
    );
  }
}

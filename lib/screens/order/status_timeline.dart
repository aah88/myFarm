import 'package:flutter/material.dart';

import '../../models/order_status.dart';

class OrderStatusTimeline extends StatelessWidget {
  final OrderStatus status;

  const OrderStatusTimeline({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final statuses = [
      OrderStatus.pending,
      OrderStatus.confirmed,
      OrderStatus.processing,
      OrderStatus.readyForDelivery,
      OrderStatus.outForDelivery,
      OrderStatus.delivered,
      OrderStatus.completed,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: statuses.map((s) {
          final isActive = statuses.indexOf(s) <= statuses.indexOf(status);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                Icon(
                  s.icon,
                  color: isActive ? Colors.green : Colors.grey,
                  size: 28,
                ),
                const SizedBox(height: 4),
                Text(
                  s.label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isActive ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_application_1/theme/design_tokens.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/bottom_nav.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Map<String, Object?> order;
  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final customer = order['customer']?.toString() ?? 'غير معروف'; 
    final item     = order['item']?.toString() ?? '—';
    final qty      = int.tryParse('${order['qty']}') ?? 0;

    return AppScaffold(
      currentTab: null,
      appBar: AppBar(title: const Text('تفاصيل الطلب')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoRow(icon: Icons.person, label: 'العميل', value: customer),
            const SizedBox(height: 12),
            _InfoRow(icon: Icons.shopping_basket, label: 'الصنف', value: item),
            const SizedBox(height: 12),
            _InfoRow(icon: Icons.numbers, label: 'الكمية', value: '$qty'),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.green),
        const SizedBox(width: 10),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w700)),
        Expanded(child: Text(value)),
      ],
    );
  }
}

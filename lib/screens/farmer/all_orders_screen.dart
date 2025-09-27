// lib/screens/orders/all_orders_farmer_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/user_provider.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../services/order_services.dart';
import '../../models/order_model.dart';
import 'package:flutter_application_1/theme/design_tokens.dart';

import '../../widgets/app_scaffold.dart';

class AllOrdersFarmerScreen extends StatefulWidget {
  const AllOrdersFarmerScreen({super.key});

  @override
  State<AllOrdersFarmerScreen> createState() => _AllOrdersFarmerScreenState();
}

class _AllOrdersFarmerScreenState extends State<AllOrdersFarmerScreen> {
  final OrderService _orderService = OrderService();
  final List<String> _expandedOrderIds = [];

  // تبويب الفلترة: 0 = الكل، 1 = بانتظار الموافقة، 2 = موافق عليها
  int _tab = 0;

  // فلترة مبنية على نص الحالة (لا تغيّر نموذجك)
  bool _matchesTab(Order o) {
    if (_tab == 0) return true;
    final s = o.status.name.toLowerCase();
    if (_tab == 1) {
      return s.contains('pending') || s.contains('wait');
    }
    return s.contains('approved') || s.contains('accept');
  }

  void _toggleExpanded(String orderId) {
    setState(() {
      if (_expandedOrderIds.contains(orderId)) {
        _expandedOrderIds.remove(orderId);
      } else {
        _expandedOrderIds.add(orderId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final cart = cartProvider.cart;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AppScaffold(
        currentTab: null,
        cartPadgeCount: cart.items.length,
        appBar: AppBar(title: const Text("📦جميع الطلبات ")),
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
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 40,
                      color: Color(0xFF9AA19A),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "No orders found",
                      style: TextStyle(color: AppColors.gray600),
                    ),
                  ],
                ),
              );
            }

            final orders = snapshot.data!;
            final displayedOrders = orders.where(_matchesTab).toList();

            return Column(
              children: [
                const SizedBox(height: 8),
                _FilterTabs(
                  current: _tab,
                  onChanged: (i) => setState(() => _tab = i),
                ),
                const SizedBox(height: 8),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Column(
                      children: [
                        for (final order in displayedOrders) ...[
                          _OrderTile(
                            order: order,
                            isExpanded: _expandedOrderIds.contains(order.id),
                            onToggle: () => _toggleExpanded(order.id),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// تبويبات الفلترة
class _FilterTabs extends StatelessWidget {
  const _FilterTabs({
    super.key,
    required this.current,
    required this.onChanged,
  });

  final int current; // 0 = الكل، 1 = بانتظار الموافقة، 2 = موافق عليها
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget tab(String text, int i) {
      final bool selected = current == i;
      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => onChanged(i),
          child: Container(
            height: 38,
            alignment: Alignment.center,
            margin: EdgeInsets.only(
              right: i == 0 ? 12 : 6,
              left: i == 2 ? 12 : 6,
            ),
            decoration: BoxDecoration(
              color: selected ? AppColors.green : const Color(0xFFEAEDEA),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                if (selected)
                  BoxShadow(
                    color: Colors.black.withOpacity(.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
              ],
            ),
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: selected ? Colors.white : const Color(0xFF3D5943),
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        tab('الكل', 0),
        tab('بانتظار الموافقة', 1),
        tab('موافق عليها', 2),
      ],
    );
  }
}

/// شارة حالة بسيطة (لا تغيّر قيمة الحالة، فقط شكل)
class _PlainStatusChip extends StatelessWidget {
  const _PlainStatusChip({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    Color border = const Color(0xFFE0E3DF);
    Color fg = const Color(0xFF3D5943);
    Color bg = const Color(0xFFF3F6F2);

    final t = text.toLowerCase();
    if (t.contains('pending') || t.contains('wait')) {
      fg = const Color(0xFF996C00);
      bg = const Color(0xFFFFF3CD);
      border = const Color(0xFFFFECB3);
    } else if (t.contains('approved') || t.contains('accept')) {
      fg = AppColors.green;
      bg = const Color(0xFFE6F3EA);
      border = const Color(0xFFC9E3D3);
    } else if (t.contains('reject') || t.contains('cancel')) {
      fg = const Color(0xFFD32F2F);
      bg = const Color(0xFFFFEBEE);
      border = const Color(0xFFF8BBD0);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }
}

/// تايل مخصّص: السهم + النص داخل نفس الـ box وبحد واحد
class _OrderTile extends StatelessWidget {
  const _OrderTile({
    required this.order,
    required this.isExpanded,
    required this.onToggle,
  });

  final Order order;
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final total = order.totalPrice();
    final dateStr = order.startDate.toDate().toString().split(' ').first;
    final statusText = order.status.name;

    // إظهار الأزرار فقط للحالات المعلّقة
    final st = statusText.toLowerCase();
    final bool isPending = st.contains('pending') ||
        st.contains('wait') ||
        st.contains('بانتظار') ||
        st.contains('انتظار') ||
        st.contains('قيد');

    const borderColor = Color(0xFFE6EAE4);

    return Column(
      children: [
        // -------- Header (السهم + النص داخل نفس الصندوق) --------
        InkWell(
  borderRadius: BorderRadius.circular(10),
  onTap: onToggle,
  child: AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(
        top: const Radius.circular(10),
        bottom: Radius.circular(isExpanded ? 0 : 10), // يتصل مع البودي عند الفتح
      ),
      border: Border.all(
        color:const Color(0xFFE6EAE4),    
      ),
    ),
            child: Row(
              children: [
                // أيقونة يسار
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAEDEA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    color: AppColors.gray600,
                  ),
                ),
                const SizedBox(width: 12),

                // النصوص
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Order",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.green,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "#${order.id}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.gray600,
                        ),
                      ),
                      Text(
                        "الإجمالي: ${total.toStringAsFixed(2)} ل.س",
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'التاريخ: $dateStr',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.gray600,
                        ),
                      ),
                    ],
                  ),
                ),

                // الحالة
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [_PlainStatusChip(text: statusText)],
                ),
                
                const SizedBox(width: 10),
                // السهم داخل نفس الصندوق + دوران بحسب الحالة
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(Icons.expand_more, color: AppColors.green),
                ),
              ],
            ),
          ),
        ),

        // -------- Body (يتوسع/ينكمش) --------
        AnimatedCrossFade(
          crossFadeState:
              isExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          duration: const Duration(milliseconds: 200),
          firstChild: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 0),        
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  right: BorderSide(color: borderColor, width: 1),
                  left: BorderSide(color: borderColor, width: 1),
                  bottom: BorderSide.none, // لا يوجد حد سفلي
                ),
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
              ),
              child: Column(
                children: [
                  // عناصر الطلب — نفس منطقك
                  ...order.items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: 48,
                              height: 48,
                              color: const Color(0xFFEAEDEA),
                              child: const Icon(
                                Icons.local_grocery_store,
                                color: Color(0xFF506A56),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.listingId,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.text,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "الكمية: ${item.qty}",
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: AppColors.gray600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            "${item.totalItemPrice().toStringAsFixed(2)} ل.س",
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),

                  const Divider(height: 22),

                  Row(
                    children: [
                      const SizedBox(width: 6),
                      const Text(
                        'الإجمالي:',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.gray600,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 6),
                      Text(
                        "${total.toStringAsFixed(2)} ل.س",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),

                  // ✅ الأزرار (شكل فقط، لا وظائف)
                  // ✅ الأزرار (شكل فقط، لا وظائف) — تظهر فقط عندما الحالة Pending
                  if (isPending) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // قبول
                        Expanded(
                          child: SizedBox(
                            height: 42,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {}, // مظهر فقط
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check, size: 18, color: Colors.white),
                                  SizedBox(width: 6),
                                  Text(
                                    'تأكيد الطلب',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                              const SizedBox(width: 10),
                              // رفض
                        Expanded(
                          child: SizedBox(
                            height: 42,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFE57373)),
                                foregroundColor: const Color(0xFFD32F2F),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {}, // مظهر فقط
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.close, size: 18),
                                  SizedBox(width: 6),
                                  Text('رفض', style: TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }
}

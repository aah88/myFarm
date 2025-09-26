// lib/screens/orders/all_orders_farmer_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/user_provider.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_1/widgets/bottom_nav.dart';

import '../../services/order_services.dart';
import '../../models/order_model.dart';
import 'package:flutter_application_1/theme/design_tokens.dart';

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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        // أبقيت عنوانك كما هو
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
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inbox_outlined, size: 40, color: Color(0xFF9AA19A)),
                    SizedBox(height: 8),
                    Text(
                      "No orders found",
                      style: TextStyle(color: Color(0xFF6A6F6A)),
                    ),
                  ],
                ),
              );
            }

            // منطقك الأصلي
            final orders = snapshot.data!;
            // عرض بحسب التبويب فقط (من دون تغيير البيانات الأصلية)
            final displayedOrders = orders.where(_matchesTab).toList();

            return Column(
              children: [
                const SizedBox(height: 8),
                // تبويبات الفلترة (لا تغيّر المنطق)
                _FilterTabs(
                  current: _tab,
                  onChanged: (i) => setState(() => _tab = i),
                ),
                const SizedBox(height: 8),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: ExpansionPanelList(
                      expandedHeaderPadding: EdgeInsets.zero,
                      elevation: 0,
                      expansionCallback: (index, _) {
                        setState(() {
                          // نفس منطقك تمامًا لكن على القائمة المعروضة
                          final orderId = displayedOrders[index].id;
                          if (_expandedOrderIds.contains(orderId)) {
                            _expandedOrderIds.remove(orderId);
                          } else {
                            _expandedOrderIds.add(orderId);
                          }
                        });
                      },
                      children: displayedOrders.map((order) {
                        final isExpanded = _expandedOrderIds.contains(order.id);

                        // نفس قيمك الأصلية
                        final total = order.totalPrice();
                        final dateStr = order.startDate.toDate().toString().split(' ').first;
                        final statusText = order.status.name;

                        return ExpansionPanel(
                          canTapOnHeader: true,
                          isExpanded: isExpanded,
                          backgroundColor: Colors
                              .transparent, // 🔧 كان لوناً أحمر؛ جعلناه شفافاً لانسجام الكارت
                          headerBuilder: (context, _) {
                            // تحسين مظهري فقط — القيم نفسها
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Container(
                                padding: const EdgeInsets.all(14), // 🔧 كان 12
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 255, 255, 255),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEAEDEA),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.receipt_long_rounded,
                                          color: Color(0xFF5C6F5E)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Order #${order.id}",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF2D2D2D),
                                            ),
                                          ),
                                          const SizedBox(height: 6), // 🔧 كان 4
                                          Text(
                                            "التاريخ: $dateStr",
                                            style: const TextStyle(
                                              fontSize: 12.5,
                                              color: Color(0xFF6A6F6A),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "الإجمالي: ${total.toStringAsFixed(2)} ل.س",
                                          style: const TextStyle(
                                            fontSize: 14, // 🔧 كان 13.5
                                            fontWeight: FontWeight.w900, // 🔧 إبراز السعر
                                            color: Color(0xFF2D2D2D),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        // شارة حالة بسيطة دون تغيير قيمة الحالة
                                        _PlainStatusChip(text: statusText),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          body: Padding(
                            padding: const EdgeInsets.only(bottom: 8, right: 6, left: 6),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // عناصر الطلب — نفس منطقك 100%
                                  ...order.items.map((item) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 6.0),
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
                                                color: Color(0xFF506A56), // 🔧 درجة أوضح قليلاً
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
                                                    color: Color(0xFF2D2D2D),
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  "الكمية: ${item.qty}",
                                                  style: const TextStyle(
                                                    fontSize: 12.5,
                                                    color: Color(0xFF6A6F6A),
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
                                              color: Color(0xFF2D2D2D),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),

                                  const Divider(height: 22),

                                  Row(
                                    children: [
                                      const Icon(Icons.summarize_outlined,
                                          color: Color(0xFF6A6F6A), size: 18),
                                      const SizedBox(width: 6),
                                      const Text(
                                        'إجمالي الطلب',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF6A6F6A),
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        "${total.toStringAsFixed(2)} ل.س",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2D2D2D),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        bottomNavigationBar: const BottomNav(current: null),
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
              left:  i == 2 ? 12 : 6,
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
    // ألوان خفيفة ثابتة دون افتراضات على النص
    Color border = const Color(0xFFE0E3DF);
    Color fg = const Color(0xFF3D5943);
    Color bg = const Color(0xFFF3F6F2);

    // تلوين تقريبي إذا احتوى النص كلمات شائعة
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), // 🔧
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.5, // 🔧
          fontWeight: FontWeight.w800, // 🔧
          color: fg,
        ),
      ),
    );
  }
}

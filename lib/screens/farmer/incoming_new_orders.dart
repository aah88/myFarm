// lib/screens/orders/all_new_orders_farmer_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/user_provider.dart';
import 'package:flutter_application_1/widgets/app_scaffold.dart';
import 'package:provider/provider.dart';

import '../../models/listing_model.dart';
import '../../providers/cart_provider.dart';
import '../../services/listing_services.dart';
import '../../services/order_services.dart';
import '../../models/order_model.dart';
import 'package:flutter_application_1/theme/design_tokens.dart';

// TODO - أزرار "قبول" و"رفض" شكلية فقط (بدون وظائف)

class AllNewOrdersFarmerScreen extends StatefulWidget {
  const AllNewOrdersFarmerScreen({super.key});

  @override
  State<AllNewOrdersFarmerScreen> createState() =>
      _AllNewOrdersFarmerScreenState();
}

class _AllNewOrdersFarmerScreenState extends State<AllNewOrdersFarmerScreen> {
  final OrderService _orderService = OrderService();

  // استخدام Set لأداء أفضل عند contains/remove/add
  final Set<String> _expandedOrderIds = <String>{};

  // نخزّن الـ Future لتجنّب إعادة الجلب على كل rebuild
  Future<List<Order>>? _pendingOrdersFuture;
  String? _lastUserId; // لتحديث المستقبل فقط لو تغيّر المستخدم

  void _toggleExpanded(String orderId) {
    setState(() {
      if (_expandedOrderIds.contains(orderId)) {
        _expandedOrderIds.remove(orderId);
      } else {
        _expandedOrderIds.add(orderId);
      }
    });
  }

  // نولّد الـ Future مرّة واحدة لكل مستخدم
  Future<List<Order>> _buildPendingFuture(String sellerId) async {
    final all = await _orderService.getPendingSellOrders(sellerId);
    // ✅ تصفية الطلبات إلى pending
    return all.toList(growable: false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final uid = context.read<UserProvider>().userId;
    if (uid != null && uid != _lastUserId) {
      _lastUserId = uid;
      _pendingOrdersFuture = _buildPendingFuture(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    // نقرأ عدد عناصر السلة لعرض الشارة في AppScaffold فقط
    final cartProvider = context.watch<CartProvider>();
    final cart = cartProvider.cart;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AppScaffold(
        currentTab: null,
        cartPadgeCount: cart.items.length,
        appBar: AppBar(title: const Text("📦 الطلبات الجديدة")),
        body: FutureBuilder<List<Order>>(
          future: _pendingOrdersFuture,
          builder: (context, snapshot) {
            if (_pendingOrdersFuture == null ||
                snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            final pendingOrders = snapshot.data ?? const <Order>[];
            if (pendingOrders.isEmpty) {
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
                      "لا توجد طلبات جديدة",
                      style: TextStyle(color: AppColors.gray600),
                    ),
                  ],
                ),
              );
            }

            // 🧠 بدل بناء كل العناصر دفعة واحدة، استخدم ListView.builder
            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              itemCount: pendingOrders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = pendingOrders[index];
                final expanded = _expandedOrderIds.contains(order.id);
                // RepaintBoundary لتقليل إعادة الرسم عند تغيّر عناصر أخرى
                return RepaintBoundary(
                  key: ValueKey(order.id),
                  child: _NewOrderTile(
                    order: order,
                    isExpanded: expanded,
                    onToggle: () => _toggleExpanded(order.id),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _PlainStatusChip extends StatelessWidget {
  const _PlainStatusChip({required this.text});
  final String text; //  النص  من البيانات (status.name)

  @override
  Widget build(BuildContext context) {
    const Color fg = Color(0xFF996C00); // لون النص
    const Color bg = Color(0xFFFFF3CD); // خلفية الشارة
    const Color br = Color(0xFFFFECB3); // حد الشارة

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: br),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }
}

/// بطاقة الطلب
class _NewOrderTile extends StatelessWidget {
  const _NewOrderTile({
    required this.order,
    required this.isExpanded,
    required this.onToggle,
  });

  final Order order;
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final ListingService firebaseListingService = ListingService();
    final total = order.totalPrice();
    final dateStr = order.startDate.toDate().toString().split(' ').first;
    final statusText = order.status.name;

    // Header
    final header = InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: const Radius.circular(10),
            bottom: Radius.circular(isExpanded ? 0 : 10),
          ),
          border: Border.all(color: const Color(0xFFE6EAE4)),
        ),
        child: Row(
          children: [
            // أيقونة
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

            // نصوص
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

            // شارة الحالة
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [_PlainStatusChip(text: statusText)],
            ),

            const SizedBox(width: 10),

            // السهم
            AnimatedRotation(
              turns: isExpanded ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(Icons.expand_more, color: AppColors.green),
            ),
          ],
        ),
      ),
    );

    // body (تفاصيل الطلب) — يبنى فقط عند الفتح
    final body = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Color(0xFFE6EAE4), width: 1),
          left: BorderSide(color: Color(0xFFE6EAE4), width: 1),
          bottom: BorderSide(color: Color(0xFFE6EAE4), width: 1),
        ),
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(10),
          bottomLeft: Radius.circular(10),
        ),
      ),
      child: Column(
        children: [
          // عناصر الطلب
          ...order.items.map((item) {
            return FutureBuilder<Listing?>(
              future: firebaseListingService.getListingById(item.listingId),
              builder: (context, snap) {
                final listing = snap.data;
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
                            color: Color(0xFF506A56),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // show name when loaded, fallback while waiting
                            Text(
                              listing?.productName ??
                                  (snap.connectionState ==
                                          ConnectionState.waiting
                                      ? '...'
                                      : '—'),
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
              },
            );
          }).toList(),

          const Divider(height: 22),

          Row(
            children: [
              const SizedBox(width: 6),
              const Text(
                'الإجمالي:',
                style: TextStyle(fontSize: 13, color: AppColors.gray600),
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

          // أزرار قبول/رفض — واجهة فقط
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
                    onPressed: () {}, // UI فقط
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check, size: 18, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          'قبول',
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
                    onPressed: () {}, // UI فقط
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.close, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'رفض',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    // نجمع الهيدر + البودي مع حركة فتح/إغلاق خفيفة الأداء
    return Column(
      children: [
        header,
        ClipRect(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: isExpanded ? body : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}

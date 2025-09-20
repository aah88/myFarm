import 'package:flutter/material.dart';
import 'package:flutter_application_1/theme/design_tokens.dart';
import 'package:flutter_application_1/models/order_status.dart';
import 'package:flutter_application_1/providers/user_provider.dart';
import 'package:flutter_application_1/widgets/bottom_nav.dart';
import 'package:provider/provider.dart';
import '../../models/full_listing.dart';
import '../../providers/cart_provider.dart';
import '../../models/local_data.dart';
import '../../providers/full_listing_provider.dart';
import '../../services/order_services.dart';

class OrderSummaryScreen extends StatefulWidget {
  const OrderSummaryScreen({super.key});

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  String? _selectedDelivery;
  String? _selectedPayment;
  Map<String, FullListing> _listingMap = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final cart = cartProvider.cart;
    final listings = context.read<FullListingProvider>().listings;
    _listingMap = {for (var l in listings) l.id: l};

    return Scaffold(
      appBar: AppBar(title: const Text("ملخص الطلب")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// --- DELIVERY METHOD ---
            DropdownButtonFormField<String>(
              value: _selectedDelivery,
              borderRadius: BorderRadius.circular(12),
              hint: const Text("اختر وسيلة التوصيل"),
              decoration: const InputDecoration(
                labelText: "اختر وسيلة التوصيل",
                hintText: "اختر وسيلة التوصيل",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.list_alt, color: Color(0xFF91958E)),
              ),
              isExpanded: true,
              items:
                  deliveryMeans
                      .map(
                        (item) => DropdownMenuItem(
                          value: item.id,
                          child: Text(item.name),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() => _selectedDelivery = value);
              },
            ),

            const SizedBox(height: 16),

            /// --- PAYMENT METHOD ---
            DropdownButtonFormField<String>(
              value: _selectedPayment,
              borderRadius: BorderRadius.circular(12),
              dropdownColor: Colors.white,
              decoration: const InputDecoration(
                labelText: "اختر وسيلة الدفع",
                hintText: "اختر وسيلة الدفع",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.list_alt, color: Color(0xFF91958E)),
              ),
              isExpanded: true,
              items:
                  paymentMeans
                      .map(
                        (item) => DropdownMenuItem(
                          value: item.id,
                          child: Text(item.name),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() => _selectedPayment = value);
              },
            ),

            const SizedBox(height: 24),

            Expanded(
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: cart.items.length,
                  separatorBuilder:
                      (_, __) => const Divider(
                        height: 1,
                        thickness: .6,
                        color: Color(0xFFE8EBE6),
                      ),
                  itemBuilder: (ctx, i) {
                    final item = cart.items[i];
                    final listing = _listingMap[item.listingId];
                    if (listing == null) {
                      return const ListTile(
                        title: Text('—'),
                        subtitle: Text('العنصر غير متاح'),
                      );
                    }

                    final lineTotal = listing.price * item.qty;

                    return ListTile(
                      // صورة مصغّرة بدل الأيقونة
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child:
                            listing.productImageUrl.isNotEmpty
                                ? Image.asset(
                                  listing.productImageUrl,
                                  width: 52,
                                  height: 52,
                                  fit: BoxFit.cover,
                                )
                                : Container(
                                  width: 52,
                                  height: 52,
                                  color: const Color(0xFFF1F3F0),
                                  child: const Icon(
                                    Icons.image,
                                    color: Colors.grey,
                                  ),
                                ),
                      ),
                      minLeadingWidth: 44,
                      minVerticalPadding: 0,

                      title: Text(
                        listing.productName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),

                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'السعر: ${listing.price}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'الكمية: ${item.qty} ${listing.unit}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),

                      trailing: Text(
                        'ل.س ${lineTotal.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: AppColors.green,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      visualDensity: VisualDensity.compact,
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// --- CONFIRM BUTTON ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed:
                    (_selectedDelivery == null || _selectedPayment == null)
                        ? null
                        : () async {
                          //TODO AAH
                          await OrderService().createOrder(
                            cart,
                            _selectedDelivery!,
                            _selectedPayment!,
                            OrderStatus.pending,
                            context.read<UserProvider>().userId!,
                          );

                          // 🔹 empty the cart after order confirmation
                          cartProvider.clearCart();

                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("✅ تم تأكيد الطلب")),
                          );

                          Navigator.pop(context); // go back after confirmation
                        },
                child: const Text(
                  "تأكيد الطلب",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(current: null),
    );
  }
}

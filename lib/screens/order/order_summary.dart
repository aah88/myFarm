// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_application_1/theme/design_tokens.dart';
import 'package:flutter_application_1/models/order_status.dart';
import 'package:flutter_application_1/providers/user_provider.dart';

import 'package:provider/provider.dart';
import '../../models/listing_model.dart';
import '../../providers/cart_provider.dart';
import '../../models/local_data.dart';
import '../../providers/all_listing_provider.dart';
import '../../services/order_services.dart';
import '../../services/listing_services.dart';
import '../../widgets/app_scaffold.dart';

class OrderSummaryScreen extends StatefulWidget {
  const OrderSummaryScreen({super.key});

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  String? _selectedDelivery;
  String? _selectedPayment;
  Map<String, Listing> _listingMap = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final cart = cartProvider.cart;
    final listings = context.read<ALLListingProvider>().listings;
    _listingMap = {for (var l in listings) l.id: l};

    return AppScaffold(
      currentTab: null,
      cartPadgeCount: cart.items.length,
      appBar: AppBar(title: const Text("ملخص الطلب")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// --- DELIVERY METHOD ---
            DropdownButtonFormField<String>(
              initialValue: _selectedDelivery,
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
              initialValue: _selectedPayment,
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
                    (_selectedDelivery == null ||
                            _selectedPayment == null ||
                            _isSubmitting) // disable while submitting
                        ? null
                        : () async {
                          setState(() => _isSubmitting = true);
                          try {
                            final ctx = context;
                            final userId = ctx.read<UserProvider>().userId!;
                            await OrderService().createOrder(
                              cart,
                              _selectedDelivery!,
                              _selectedPayment!,
                              OrderStatus.pending,
                              userId,
                            );
                            if (!mounted) return;
                            for (final cartItem in cart.items) {
                              await ListingService().finalizeSingleListing(
                                listingId: cartItem.listingId,
                                qtyToBuy: cartItem.qty,
                              );
                            }
                            cartProvider.clearCart();
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(content: Text("✅ تم تأكيد الطلب")),
                            );
                            Navigator.pop(ctx);
                          } finally {
                            if (mounted) setState(() => _isSubmitting = false);
                          }
                        },
                child:
                    _isSubmitting
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Text(
                          "تأكيد الطلب",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

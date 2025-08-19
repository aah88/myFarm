// lib/screens/cart/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_1/models/full_listing.dart';
import '../../providers/cart_provider.dart';
import '../../services/firebase_service.dart';

import '../../widgets/app_scaffold.dart';
import '../../widgets/bottom_nav.dart';
import '../customer/all_listings.dart';

// 🎨 Tokens
import '../../theme/design_tokens.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _loading = true;
  Map<String, FullListing> _listingMap = {};

  @override
  void initState() {
    super.initState();
    _loadListingDetails();
  }

  Future<void> _loadListingDetails() async {
    final cart = context.read<CartProvider>().cart;
    final listingIds = cart.items.map((i) => i.listingId).toList();

    final listings = await _firebaseService.getFullListingsByIds(listingIds);
    _listingMap = {for (var l in listings) l.id: l};

    if (mounted) setState(() => _loading = false);
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    await _loadListingDetails();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final cart = cartProvider.cart;

    return AppScaffold(
      currentTab: AppTab.cart,
      appBar: AppBar(
        title: const Text('سلة المشتريات', style: TextStyle(color: Color(0xFF2E7D32))),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : cart.items.isEmpty
              ? const _EmptyCart()
              : Column(
                  children: [
                    // القائمة
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _refresh,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                            Spacing.lg, Spacing.md, Spacing.lg, Spacing.md),
                          itemCount: cart.items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: Spacing.md),
                          itemBuilder: (context, index) {
                            final item = cart.items[index];
                            final listing = _listingMap[item.listingId];
                            if (listing == null) return const SizedBox.shrink();

                            return Dismissible(
                              key: ValueKey('cart-${item.listingId}'),
                              direction: DismissDirection.endToStart,
                              onDismissed: (_) =>
                                  cartProvider.removeItem(item.listingId),
                              background: const _DismissBg(),
                              child: ListTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: Borders.rSm,
                                  side: Borders.thin,
                                ),
                                tileColor: AppColors.white,
                                leading: ClipRRect(
                                  borderRadius: Borders.rSm,
                                  child: _ProductImage(url: listing.productImageUrl),
                                ),
                                title: Text(
                                  listing.productName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              // ✅ الوحدة على سطر، السعر على سطر
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: Spacing.xs),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'الوحدة: ${listing.unit}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${listing.price} ل.س',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                trailing: ConstrainedBox(
                                  constraints: const BoxConstraints(minWidth: 96),
                                  child: _QtyInline(
                                    qty: item.qty,
                                    onDec: () {
                                      if (item.qty > 1) {
                                        cartProvider.updateQty(
                                            item.listingId, item.qty - 1);
                                      } else {
                                        cartProvider.removeItem(item.listingId);
                                      }
                                    },
                                    onInc: () => cartProvider.updateQty(
                                        item.listingId, item.qty + 1),
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: Spacing.md,
                                  vertical: Spacing.sm,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // شريط سفلي بسيط: الإجمالي + CTA
                    if (cart.items.isNotEmpty)
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          border: const Border(
                            top: BorderSide(color: AppColors.gray200, width: 1),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.lg, vertical: Spacing.md),
                        child: SafeArea(
                          top: false,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'الإجمالي: ${cartProvider.totalPrice(_listingMap)} ل.س',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  // TODO: الدفع
                                },
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(140, 44),
                                ),
                                child: const Text('إتمام الشراء'),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  final String url;
  const _ProductImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: url.isNotEmpty
          ? Image.asset(url, fit: BoxFit.cover)
          : Container(
              color: AppColors.gray100,
              child: const Icon(Icons.image, color: Colors.grey),
            ),
    );
  }
}

class _QtyInline extends StatelessWidget {
  final int qty;
  final VoidCallback onDec;
  final VoidCallback onInc;

  const _QtyInline({
    required this.qty,
    required this.onDec,
    required this.onInc,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _miniIconButton(Icons.remove, onDec, disabled: qty <= 1),
        const SizedBox(width: Spacing.xs),
        Text(
          '$qty',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: Spacing.xs),
        _miniIconButton(Icons.add, onInc),
      ],
    );
  }

  Widget _miniIconButton(IconData icon, VoidCallback onTap, {bool disabled = false}) {
    return IconButton(
      onPressed: disabled ? null : onTap,
      icon: Icon(icon, color: disabled ? Colors.grey : Colors.black87),
      iconSize: 18,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      splashRadius: 18,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _DismissBg extends StatelessWidget {
  const _DismissBg();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      decoration: BoxDecoration(
        color:  AppColors.danger,
        borderRadius: Borders.rSm,
      ),
      child: const Icon(Icons.delete, color: AppColors.white),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: Spacing.xl, vertical: Spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shopping_cart_outlined, size: 72, color: Colors.grey),
            const SizedBox(height: Spacing.md),
            const Text('السلة فارغة'),
            const SizedBox(height: Spacing.sm),
            const Text('أضف منتجات إلى السلة لعرضها هنا.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: Spacing.lg),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => AllListingsScreen()),
                );
              },
              icon: const Icon(Icons.storefront_outlined),
              label: const Text('تصفح المنتجات'),
            ),
          ],
        ),
      ),
    );
  }
}

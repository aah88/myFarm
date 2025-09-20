// lib/screens/cart/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/full_listing.dart';
import 'package:flutter_application_1/providers/full_listing_provider.dart';
import 'package:flutter_application_1/screens/customer/all_listings_screen.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../services/listing_services.dart';

// مهم: AppScaffold يضيف BottomNav، ونحتاج AppTab من bottom_nav.dart
import '../../widgets/app_scaffold.dart';
import '../../widgets/bottom_nav.dart';
import '../order/order_summary.dart';

// 🎨 Tokens
import '../../theme/design_tokens.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final ListingService _firebaseListingService = ListingService();
  bool _loading = true;
  Map<String, FullListing> _listingMap = {};

  @override
  void initState() {
    super.initState();
    _loadListingDetails();
  }

  Future<void> _loadListingDetails() async {
    final cart = context.read<CartProvider>().cart;
    final listingIds = cart.items.map((item) => item.listingId).toList();
    final listings = await _firebaseListingService.getFullListingsByIds(
      listingIds,
    );

    _listingMap = {for (var l in listings) l.id: l};

    if (mounted) {
      setState(() => _loading = false);
      context.read<FullListingProvider>().setListings(listings);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final cart = cartProvider.cart;

    return AppScaffold(
      currentTab: AppTab.cart, // ✅ يفعّل تبويب السلة في BottomNav
      appBar: AppBar(
        title: const Text(
          '🛒 سلة المشتريات',
          style: TextStyle(color: AppColors.green),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : cart.items.isEmpty
              ? const _EmptyCart()
              : Column(
                children: [
                  // القائمة قابلة للتمدد
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        Spacing.lg,
                        Spacing.md,
                        Spacing.lg,
                        Spacing.md,
                      ),
                      itemCount: cart.items.length,
                      itemBuilder: (context, index) {
                        final cartItem = cart.items[index];
                        final listing = _listingMap[cartItem.listingId];
                        if (listing == null) return const SizedBox();

                        return Dismissible(
                          key: ValueKey(
                            'cart-${cartItem.listingId}',
                          ), // تأكّد أنها فريدة
                          direction:
                              DismissDirection
                                  .endToStart, // اسحب يمين↔يسار (أنسب لـ RTL)
                          onDismissed:
                              (_) =>
                                  cartProvider.removeItem(cartItem.listingId),

                          // لا نعرض خلفية للاتجاه المعاكس
                          background: const SizedBox.shrink(),

                          // عند السحب من الـend إلى الـstart (يسار→يمين في RTL)
                          secondaryBackground: Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppColors.danger,
                              borderRadius: BorderRadius.circular(
                                8,
                              ), // 👈 الزوايا الدائرية
                            ),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),

                          child: Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: Padding(
                              padding: const EdgeInsets.all(
                                8,
                              ), // ← مهم: لازم تكون باسم البراميتر
                              child: Row(
                                children: [
                                  // --- نفس محتواك كما هو ---
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child:
                                        (listing.productImageUrl).isNotEmpty
                                            ? Image.asset(
                                              listing.productImageUrl,
                                              height: 70,
                                              width: 70,
                                              fit: BoxFit.cover,
                                            )
                                            : Container(
                                              height: 70,
                                              width: 70,
                                              color: const Color(0xFFF1F3F0),
                                              child: const Icon(
                                                Icons.image,
                                                color: Colors.grey,
                                              ),
                                            ),
                                  ),
                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          listing.productName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          "المزارع: ${listing.farmerName}",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          "${listing.price} ل.س / ${listing.unit}",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: AppColors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "الإجمالي: ${cartProvider.itemTotal(cartItem.listingId, cartItem.qty, _listingMap)} ل.س",
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.orange,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // تحكم بالكمية (أفقي − qty +) كما هو عندك
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.remove_circle_outline,
                                        ),
                                        onPressed: () {
                                          if (cartItem.qty > 1) {
                                            cartProvider.updateQty(
                                              cartItem.listingId,
                                              cartItem.farmerId,
                                              cartItem.qty - 1,
                                            );
                                          } else {
                                            cartProvider.removeItem(
                                              cartItem.listingId,
                                            );
                                          }
                                        },
                                        padding: EdgeInsets.zero,
                                        constraints:
                                            const BoxConstraints.tightFor(
                                              width: 30,
                                              height: 30,
                                            ),
                                        visualDensity: const VisualDensity(
                                          horizontal: -4,
                                          vertical: -4,
                                        ),
                                        splashRadius: 16,
                                        iconSize: 20,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        "${cartItem.qty}",
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          height: 1.0,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.add_circle_outline,
                                        ),
                                        onPressed:
                                            () => cartProvider.updateQty(
                                              cartItem.listingId,
                                              cartItem.farmerId,
                                              cartItem.qty + 1,
                                            ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                          minWidth: 36,
                                          minHeight: 36,
                                        ),
                                        splashRadius: 20,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // ✅ شريط المجموع أسفل الـ body (فوق الـ BottomNav)
                  if (cart.items.isNotEmpty)
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        border: const Border(
                          top: BorderSide(color: AppColors.gray200, width: 1),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.lg,
                        vertical: Spacing.md,
                      ),
                      child: SafeArea(
                        top: false,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "الإجمالي: ${cartProvider.totalPrice(_listingMap)} ل.س",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => OrderSummaryScreen(),
                                  ),
                                );

                                // TODO: تابع عملية الدفع
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.green,
                                minimumSize: const Size(140, 40),
                              ),
                              child: const Text("إتمام الشراء"),
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

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.xl,
          vertical: Spacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.shopping_cart_outlined,
              size: 72,
              color: AppColors.green,
            ),
            const SizedBox(height: Spacing.md),
            const Text('السلة فارغة'),
            const SizedBox(height: Spacing.sm),
            const Text(
              'أضف منتجات إلى السلة لعرضها هنا.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: Spacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => AllListingsScreen()),
                  );
                },
                child: const Text(" تصفح المنتجات"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

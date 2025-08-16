// lib/screens/cart/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/full_listing.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../services/firebase_service.dart';
import '../../models/listing_model.dart';

// مهم: AppScaffold يضيف BottomNav، ونحتاج AppTab من bottom_nav.dart
import '../../widgets/app_scaffold.dart';
import '../../widgets/bottom_nav.dart';

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

    // IDs المطلوبة فقط
    final listingIds = cart.items.map((item) => item.listingId).toList();

    // اجلب التفاصيل
    final listings = await _firebaseService.getFullListingsByIds(listingIds);

    // حوّلها لخريطة للوصول السريع
    _listingMap = {for (var l in listings) l.id: l};

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final cart = cartProvider.cart;

    return AppScaffold(
      currentTab: AppTab.cart, // ✅ يفعّل تبويب السلة في BottomNav
      appBar: AppBar(
        title: const Text("🛒 سلة المشتريات"),
        backgroundColor: Colors.green, // غيّرها لو تبغى تتماشى مع ثيمك
        elevation: 0,
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : cart.items.isEmpty
              ? const Center(child: Text("السلة فارغة"))
              : Column(
                  children: [
                    // القائمة قابلة للتمدد
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                        itemCount: cart.items.length,
                        itemBuilder: (context, index) {
                          final cartItem = cart.items[index];
                          final listing = _listingMap[cartItem.listingId];
                          if (listing == null) return const SizedBox();

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                children: [
                                  // صورة المنتج
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: ('' /* listing.imageUrl */).isNotEmpty
                                        ? Image.network(
                                            '', // listing.imageUrl
                                            height: 70,
                                            width: 70,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            height: 70,
                                            width: 70,
                                            color: const Color(0xFFF1F3F0),
                                            child: const Icon(Icons.image, color: Colors.grey),
                                          ),
                                  ),
                                  const SizedBox(width: 12),

                                  // معلومات
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          " المنتج: ${listing.productName}", 
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        Text(
                                          "المزارع: ${listing.farmerName}", 
                                          style: TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                        Text(
                                          "الوحدة: ${listing.unit}",
                                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                        Text(
                                          "${listing.price} ل.س",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // تحكم بالكمية
                                  Column(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.add_circle_outline),
                                        onPressed: () => cartProvider.updateQty(
                                          cartItem.listingId,
                                          cartItem.qty + 1,
                                        ),
                                      ),
                                      Text("${cartItem.qty}", style: const TextStyle(fontSize: 16)),
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline),
                                        onPressed: () {
                                          if (cartItem.qty > 1) {
                                            cartProvider.updateQty(
                                              cartItem.listingId,
                                              cartItem.qty - 1,
                                            );
                                          } else {
                                            cartProvider.removeItem(cartItem.listingId);
                                          }
                                        },
                                      ),
                                    ],
                                  ),

                                  // حذف
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => cartProvider.removeItem(cartItem.listingId),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // ✅ شريط المجموع أسفل الـ body (فوق الـ BottomNav)
                    if (cart.items.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            top: BorderSide(color: Color(0xFFE8EBE6), width: 1),
                          ),
                        ),
                        child: SafeArea(
                          top: false,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "الإجمالي: ${cartProvider.totalPrice(_listingMap)} ل.س",
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  // TODO: تابع عملية الدفع
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  minimumSize: const Size(120, 40),
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

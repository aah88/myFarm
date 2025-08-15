import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/firebase_service.dart';
import '../../models/listing_model.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _loading = true;
  Map<String, Listing> _listingMap = {};

  @override
  void initState() {
    super.initState();
    _loadListingDetails();
  }

  Future<void> _loadListingDetails() async {
    final cart = context.read<CartProvider>().cart;

    // Get all listing IDs from cart
    final listingIds = cart.items.map((item) => item.listingId).toList();

    // Fetch only needed listings
    final listings = await _firebaseService.getListingsByIds(listingIds);

    // Map for quick access
    _listingMap = {for (var l in listings) l.id: l};

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final cart = cartProvider.cart;

    return Scaffold(
      appBar: AppBar(
        title: const Text("🛒 سلة المشتريات"),
        backgroundColor: Colors.green[700],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : cart.items.isEmpty
              ? const Center(child: Text("السلة فارغة"))
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final cartItem = cart.items[index];
                    final listing = _listingMap[cartItem.listingId];

                    if (listing == null) {
                      return const SizedBox(); // Listing not found
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            // Product Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                '',//listing.imageUrl,
                                height: 70,
                                width: 70,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Product Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Product name',//listing.productName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  Text('المزارع',//"المزارع: ${listing.farmerName}",
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey)),
                                  Text("الوحدة: ${listing.unit}",
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey)),
                                  Text("${listing.price} ل.س",
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),

                            // Qty Controls
                            Column(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () {
                                    cartProvider.updateQty(
                                        cartItem.listingId, cartItem.qty + 1);
                                  },
                                ),
                                Text("${cartItem.qty}",
                                    style: const TextStyle(fontSize: 16)),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () {
                                    if (cartItem.qty > 1) {
                                      cartProvider.updateQty(
                                          cartItem.listingId,
                                          cartItem.qty - 1);
                                    } else {
                                      cartProvider.removeItem(
                                          cartItem.listingId);
                                    }
                                  },
                                ),
                              ],
                            ),

                            // Delete Button
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                cartProvider.removeItem(cartItem.listingId);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: cart.items.isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(12),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "الإجمالي: ${cartProvider.totalPrice(_listingMap)} ل.س",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Proceed to checkout logic
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700]),
                    child: const Text("إتمام الشراء"),
                  )
                ],
              ),
            )
          : null,
    );
  }
}

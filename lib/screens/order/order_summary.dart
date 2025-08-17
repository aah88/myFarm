import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/full_listing.dart';
import '../../providers/cart_provider.dart';
import '../../models/cart_model.dart';
import '../../services/firebase_service.dart';

class OrderSummaryScreen extends StatefulWidget {
  const OrderSummaryScreen({super.key});
  

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  String? _selectedDelivery;
  String? _selectedPayment;
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

    return Scaffold(
      appBar: AppBar(
        title: const Text("ملخص الطلب"),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// --- ORDER SUMMARY ---
            const Text(
              "مراجعة الطلب",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

       

            /// --- DELIVERY METHOD ---
            const Text(
              "اختر وسيلة التوصيل",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: _selectedDelivery,
              hint: const Text("اختر وسيلة التوصيل"),
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: "pickup", child: Text("استلام من المزرعة")),
                DropdownMenuItem(value: "courier", child: Text("خدمة توصيل")),
              ],
              onChanged: (value) {
                setState(() => _selectedDelivery = value);
              },
            ),

            const SizedBox(height: 16),

            /// --- PAYMENT METHOD ---
            const Text(
              "اختر وسيلة الدفع",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: _selectedPayment,
              hint: const Text("اختر وسيلة الدفع"),
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: "cash", child: Text("الدفع عند الاستلام")),
                DropdownMenuItem(value: "card", child: Text("بطاقة بنكية")),
              ],
              onChanged: (value) {
                setState(() => _selectedPayment = value);
              },
            ),

            const SizedBox(height: 24),
     Expanded(
              child: ListView.builder(
                itemCount: cart.items.length,
                itemBuilder: (ctx, i) {
                  final item = cart.items[i];
                  final listing = _listingMap[item.listingId];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: const Icon(Icons.shopping_bag),
                      title: Text("${listing?.productName}"),
                      subtitle: Text("الكمية: ${item.qty} ${listing?.unit}"),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),
            /// --- CONFIRM BUTTON ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: (_selectedDelivery == null || _selectedPayment == null)
                    ? null
                    : () async {
                        // 🔹 here you would save the order to Firestore
                        // e.g., await FirebaseService().createOrder(cart, _selectedDelivery!, _selectedPayment!);

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
    );
  }
}

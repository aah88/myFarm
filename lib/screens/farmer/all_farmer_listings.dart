import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_1/models/cart_model.dart';
import 'package:flutter_application_1/models/full_listing.dart';
import 'package:flutter_application_1/widgets/bottom_nav.dart';

import '../../providers/cart_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/firebase_service.dart';
import '../../widgets/product_listing_card.dart'; // ✅ الكارت الجديد

class AllFarmerListingsScreen extends StatefulWidget {
  const AllFarmerListingsScreen({super.key});

  @override
  State<AllFarmerListingsScreen> createState() =>
      _AllFarmerListingsScreenState();
}

class _AllFarmerListingsScreenState extends State<AllFarmerListingsScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  final String farmerImage =
      'https://cdn-icons-png.flaticon.com/512/3595/3595455.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
                title: const Text(
          'إدارة منتجاتك',
          style: TextStyle(color: Color(0xFF2E7D32)),
        )
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // 🌿 Welcome Section
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'حدّث محاصيلك بسهولة:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                          "اضغط على أحد المنتجات أدناه لتعديل المنتج وإكمال العملية.",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          height: 1.25,
                        ),
                      ),
                      SizedBox(height: 12),
                    ],
              ),
            ),

            // 🛒 Product Grid
            Expanded(
              child: FutureBuilder<List<FullListing>>(
                future: _firebaseService.getFarmerFullListings(
                  context.read<UserProvider>().userId!,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('حدث خطأ: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('لا توجد منتجات متاحة'));
                  }

                  final listings = snapshot.data!;
                  return Directionality(
                    textDirection: TextDirection.rtl,
                    child: GridView.builder(
                      padding: const EdgeInsets.only(top: 4),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent:
                                250, // 👈 أقصى عرض للكارت الواحد
                            childAspectRatio:
                                0.9, // 👈 اضبط حسب ارتفاع/عرض الكارت عندك
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemCount: listings.length,
                      itemBuilder: (context, index) {
                        final listing = listings[index];
                        return ProductListingCard(
                          imageUrl: listing.productImageUrl,
                          title: listing.productName,
                          rating: listing.rating,
                          price: listing.price,
                          farmerName: listing.farmerName,
                          distance: 0,
                          onAddToCart: () {}, // ممكن تركه فاضي
                          action: ListingCardAction.edit,
                          onEdit: () {
                            // افتح شاشة التعديل مثلاً
                            Navigator.pushNamed(context, '/edit-listing', arguments: listing.id);
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(current: null),
    );
  }
}

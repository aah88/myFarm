import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/customer/listing_detail_screen.dart';
import 'package:flutter_application_1/theme/design_tokens.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_1/models/cart_model.dart';
import 'package:flutter_application_1/models/full_listing.dart';
import 'package:flutter_application_1/widgets/bottom_nav.dart';

import '../../providers/cart_provider.dart';
import '../../services/listing_services.dart';
import '../../widgets/product_listing_card.dart'; // ✅ الكارت الجديد
import 'package:flutter_application_1/widgets/letters_bar.dart';
import 'package:flutter_application_1/widgets/section_header.dart'; 

class AllListingsScreen extends StatefulWidget {
  
  const AllListingsScreen({super.key, this.categoryId});
  final String? categoryId; // ID of the selected category

  @override
  State<AllListingsScreen> createState() => _AllListingsScreenState();
}

class _AllListingsScreenState extends State<AllListingsScreen> {

  final ListingService _firebaseListingService = ListingService();
  final String farmerImage ='https://cdn-icons-png.flaticon.com/512/3595/3595455.png';

  String _selectedLetter = defaultSelectedLetter;

    late Future<List<FullListing>> _fullListingFuture;


  @override
  void initState() {
    super.initState();
    _fullListingFuture = widget.categoryId == null ?  _firebaseListingService.getFullListings(): _firebaseListingService.getFullListingsByCategory(widget.categoryId!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("كل المنتجات",style: TextStyle(color: AppColors.green),)),
      body: FutureBuilder<List<FullListing>>(
        future: _fullListingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('لا توجد منتجات متاحة'));
          }

          final listings = snapshot.data!;
          final filtered = filterBySelectedLetter<FullListing>(
            listings,
            (l) => l.productName,
            _selectedLetter,
          );

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [

              // 🏷️ العنوان القابل لإعادة الاستخدام
              const SliverSectionHeader(
                title: 'اختر منتجك بسهولة:',
                subtitle: 'استخدم شريط الحروف لتصفية القائمة و الانتقال إلى المنتج الذي تريده بسرعة',
              ),

              // 🔠 شريط الحروف
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: LettersBar(
                    selectedLetter: _selectedLetter,
                    onLetterSelected: (letter) => setState(() => _selectedLetter = letter),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // 🧺 حالة عدم وجود نتائج للحرف المختار
              if (filtered.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text('لا توجد منتجات بهذا الحرف.')),
                )
              else
                // 🛒 شبكة المنتجات (SliverGrid بدل GridView داخل Sliver)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 250,
                      childAspectRatio: 0.9,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final listing = filtered[index];
                        return InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailScreen(),
                              ),
                            );
                          },
                          child: ProductListingCard(
                            imageUrl: listing.productImageUrl,
                            title: listing.productName,
                            rating: listing.rating,
                            price: listing.price,
                            farmerName: listing.farmerName,
                            distance:
                                5.2, // replace with actual distance müss berechnet werden
                            onAddToCart: () {
                              context.read<CartProvider>().addItem(
                                CartItem(
                                  listingId: listing.id,
                                  farmerId: listing.userId,
                                  price: listing.price,
                                  qty: 1,
                                ),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "${listing.productName} تمت إضافته إلى السلة",
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                      childCount: filtered.length,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            ],
          );
        },
      ),

      bottomNavigationBar: const BottomNav(current: null),
    );
  }
}

// lib/screens/home/home_screen_farmer.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Models
import 'package:flutter_application_1/models/category_model.dart';
import 'package:flutter_application_1/models/full_listing.dart';
import 'package:flutter_application_1/models/cart_model.dart';

// Providers & services
import '../../providers/user_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/listing_provider.dart';
import '../../services/firebase_service.dart';

// UI & routing
import '../../widgets/app_scaffold.dart';
import '../../widgets/bottom_nav.dart';
import '../category/choose_category_screen.dart';
import '../product/choose_product_screen.dart';
import '../customer/all_listings.dart';
import '../../widgets/product_listing_card.dart'; // ✅ الكارت الجديد

// Design tokens
import '../../theme/design_tokens.dart';

class HomeScreenUser extends StatefulWidget {
  const HomeScreenUser({super.key});

  @override
  State<HomeScreenUser> createState() => _HomeScreenUserState();
}

class _HomeScreenUserState extends State<HomeScreenUser> {
  final FirebaseService _firebaseService = FirebaseService();
  late Future<List<ProductCategory>> _futureCategories;

  @override
  void initState() {
    super.initState();
    _futureCategories = _firebaseService.getCategory();

    // تهيئة مزودي المستخدم والسلة
    Future.microtask(() {
      if (!mounted) return;
      final userProvider = context.read<UserProvider>();
      userProvider.setUserId('TeGmDtcdpChIKwJYGF3zTcD804o2');

      final cartProvider = context.read<CartProvider>();
      cartProvider.loadCart('TeGmDtcdpChIKwJYGF3zTcD804o2');
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentTab: AppTab.home,
      body: ListView(
        padding: const EdgeInsets.all(Spacing.lg),
        children: [
          // ====== Header ======
          Container(
            constraints: const BoxConstraints(minHeight: 120, maxHeight: 150),
            decoration: BoxDecoration(
              borderRadius: Borders.rSm,
              image: const DecorationImage(
                image: AssetImage('lib/assets/images/farmer_header.jpg'),
                fit: BoxFit.cover,
              ),
              boxShadow: Shadows.cardSm,
            ),
            padding: const EdgeInsets.all(Spacing.lg),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أهلاً بك!\nادخل منتجاتك وابدأ البيع',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    height: 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: Spacing.md),

          // ====== الأصناف + عرض الكل ======
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '  الأصناف',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.green,
                    ),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChooseCategoryScreen()),
                  );
                },
                icon: const Icon(Icons.chevron_left, size: 18, color: AppColors.danger),
                label: const Text('عرض الكل', style: TextStyle(color: AppColors.danger)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),

          const SizedBox(height: Spacing.md),

          // ====== سلايدر الأصناف ======
          FutureBuilder<List<ProductCategory>>(
            future: _futureCategories,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 96,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return Text('تعذّر تحميل الأصناف: ${snapshot.error}');
              }

              final categories = snapshot.data ?? [];
              if (categories.isEmpty) return const SizedBox.shrink();

              return SizedBox(
                height: 96,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: Spacing.md),
                  itemBuilder: (context, i) {
                    final c = categories[i];
                    return _CategoryChipSmall(
                      title: c.name,
                      imageUrl: c.imageUrl,
                      onTap: () {
                        context.read<ListingProvider>().setCategoryId(c.id);
                        context.read<ListingProvider>().setUserId(
                              context.read<UserProvider>().userId!,
                            );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChooseProductScreen(categoryId: c.id),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),

          const SizedBox(height: Spacing.lg),

          // ====== الأكثر مبيعاً + عرض الكل ======
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                ' الأكثر مبيعاً',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.green,
                    ),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AllListingsScreen()),
                  );
                },
                icon: const Icon(Icons.chevron_left, size: 18, color: AppColors.danger),
                label: const Text('عرض الكل', style: TextStyle(color: AppColors.danger)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),

          const SizedBox(height: Spacing.md),

          // ====== شبكة المنتجات (مثل الصورة) ======
          FutureBuilder<List<FullListing>>(
            future: _firebaseService.getFullListings(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('حدث خطأ: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text('لا توجد منتجات متاحة');
              }

              final listings = snapshot.data!;

              return Directionality(
                textDirection: TextDirection.rtl,
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(top: 4),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: listings.length,
                  itemBuilder: (context, i) {
                    final l = listings[i];
                    return ProductListingCard(
                      imageUrl: l.productImageUrl,
                      title: l.productName,
                      rating: l.rating,
                      price: l.price,
                      farmerName: l.farmerName,
                      distance: 5.2, // replace with actual distance müss berechnet werden
                      onAddToCart: () {
                        context.read<CartProvider>().addItem(
                              CartItem(listingId: l.id, qty: 1),
                            );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("${l.productName} تمت إضافته إلى السلة")),
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),

          const SizedBox(height: Spacing.xl),
        ],
      ),
    );
  }
}

class _CategoryChipSmall extends StatelessWidget {
  const _CategoryChipSmall({
    required this.title,
    required this.imageUrl,
    required this.onTap,
  });

  final String title;
  final String imageUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(16);
    return InkWell(
      onTap: onTap,
      borderRadius: r,
      child: Container(
        width: 95,
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F6F2),
          borderRadius: r,
          border: Border.all(color: const Color(0xFFE8EBE6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            imageUrl.startsWith('http')
                ? Image.network(imageUrl, height: 45, fit: BoxFit.contain)
                : Image.asset(imageUrl, height: 45, fit: BoxFit.contain),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// lib/screens/home/home_screen_farmer.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/category_model.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/user_provider.dart';
import '../category/choose_category_screen.dart';
import '../../services/firebase_service.dart';

import '../../widgets/app_scaffold.dart';
import '../../widgets/bottom_nav.dart';
import '../customer/all_listings.dart';

// 🧩 Tokens

import '../../theme/design_tokens.dart'; 
import '../../providers/listing_provider.dart';          // ⬅ جديد
import '../product/choose_product_screen.dart';          // ⬅ جديد

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
  Future.microtask(() {
    if (!mounted) return; // ✅ guard against context after dispose

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
          // Header Image
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

          // عنوان " الأصناف " + "عرض الكل"
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

            // 🔻 سلايدر الأصناف

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
                      imageUrl: c.imageUrl, // مسار أصل/شبكة
                      onTap: () {
                        // نفس تدفّق صفحة الأصناف:
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

          const SizedBox(height: Spacing.md),

          // عنوان  الأكثر مبيعاً" + "عرض الكل"
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
                  // TODO: انتقل لصفحة كل المنتجات الأكثر مبيعًا
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

          // المنتجات (سلايدر)
          FutureBuilder<List<Product>>(
            future: _firebaseService.getProducts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('حدث خطأ: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text('لا توجد منتجات متاحة');
              }

              final products = snapshot.data!;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: products.map((product) {
                    return Padding(
                      padding: const EdgeInsets.only(right: Spacing.md),
                      child: ProductCard(
                        imageUrl: product.imageUrl,
                        title: product.name,
                      ),
                    );
                  }).toList(),
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

class StatCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final double iconSize;

  const StatCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    this.iconSize = 22,
  });

  String _formatCount(int n) => n > 99 ? '99+' : '$n';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: Borders.rSm,
        border: Border.fromBorderSide(Borders.thin),
        boxShadow: Shadows.cardSm,
      ),
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.green, size: iconSize),
          const SizedBox(height: Spacing.sm),
          Text(
            _formatCount(count),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: Spacing.xs),
          Text(title, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final String imageUrl;
  final String title;

  const ProductCard({
    super.key,
    required this.imageUrl,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(Spacing.md - 2), // 10px
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.gray200),
        borderRadius: Borders.rSm,
        boxShadow: Shadows.cardXs,
      ),
      child: Column(
        children: [
          Image.asset(
            imageUrl,
            height: 86,
            fit: BoxFit.contain, // مناسب لصور PNG/شفافة
          ),
          const SizedBox(height: Spacing.sm),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: Spacing.xs),
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
            // استخدم Image.asset أو Image.network حسب نوع الرابط
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



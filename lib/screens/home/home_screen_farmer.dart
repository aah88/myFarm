// lib/screens/home/home_screen_farmer.dart
import 'package:flutter/material.dart';
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

class HomeScreenFarmer extends StatelessWidget {
  HomeScreenFarmer({super.key});

  final FirebaseService _firebaseService = FirebaseService();
 

  @override
  Widget build(BuildContext context) {
    //TODO Löschen AHMAD
     context.read<UserProvider>().setUserId('TeGmDtcdpChIKwJYGF3zTcD804o2');
     final cartProvider = Provider.of<CartProvider>(context, listen: false);
     cartProvider.loadCart('TeGmDtcdpChIKwJYGF3zTcD804o2'); //
     // 
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

          // الإحصائيات
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: Spacing.md,
            crossAxisSpacing: Spacing.md,
            children: const [
              StatCard(title: 'المنتجات', count: 5, icon: Icons.shopping_basket),
              StatCard(title: 'الطلبات', count: 3, icon: Icons.shopping_cart),
              StatCard(title: 'التقارير', count: 1, icon: Icons.bar_chart),
              StatCard(title: 'طلبات جديدة', count: 103, icon: Icons.fiber_new),
              StatCard(title: 'إحصائيات', count: 1, icon: Icons.analytics),
              StatCard(title: 'التقييمات', count: 3, icon: Icons.star_rounded),
            ],
          ),

          const SizedBox(height: Spacing.lg),

          // زر شراء (ثانوي)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AllListingsScreen()),
              ),
              child: const Text('شراء منتج'),
            ),
          ),

          const SizedBox(height: Spacing.md),

          // زر إضافة منتج (أساسي)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChooseCategoryScreen()),
                );
              },
              child: const Text('إضافة منتج'),
            ),
          ),

          const SizedBox(height: Spacing.lg),

          // عنوان "منتجاتي الأكثر مبيعاً" + "عرض الكل"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'منتجاتي الأكثر مبيعاً',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: BrandColors.green,
                    ),
              ),
              TextButton.icon(
                onPressed: () {
                  // TODO: انتقل لصفحة كل المنتجات الأكثر مبيعًا
                },
                icon: const Icon(Icons.chevron_left, size: 18, color: BrandColors.danger),
                label: const Text('عرض الكل', style: TextStyle(color: BrandColors.danger)),
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
        color: BrandColors.white,
        borderRadius: Borders.rSm,
        border: Border.fromBorderSide(Borders.thin),
        boxShadow: Shadows.cardSm,
      ),
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: BrandColors.green, size: iconSize),
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
        color: BrandColors.white,
        border: Border.all(color: BrandColors.gray200),
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

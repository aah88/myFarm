import 'package:flutter/material.dart';
import '../../models/category_model.dart';
import '../../services/firebase_service.dart';

class ChooseCategoryScreen extends StatelessWidget {
  final FirebaseService _firebaseService = FirebaseService();

  final String farmerImage =
      'https://cdn-icons-png.flaticon.com/512/3595/3595455.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // العنوان الأخضر
            Container(
              decoration: BoxDecoration(
                color: Colors.green[700],
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Image.network(farmerImage, height: 60),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'NEW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // الإحصائيات
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: const [
                StatCard(title: 'المنتجات', count: 5, icon: Icons.shopping_basket),
                StatCard(title: 'الطلبات', count: 3, icon: Icons.shopping_cart),
                StatCard(title: 'التقارير', count: 1, icon: Icons.bar_chart),
                StatCard(title: 'طلبات جديدة', count: 3, icon: Icons.fiber_new),
                StatCard(title: 'إحصائيات المبيعات', count: 1, icon: Icons.analytics),
                StatCard(title: 'التقييمات والمراجعات', count: 3, icon: Icons.reviews),
              ],
            ),

            const SizedBox(height: 16),

            // زر إضافة منتج
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  // Navigate or open product addition screen
                },
                child: const Text('إضافة منتج'),
              ),
            ),

            const SizedBox(height: 24),

            // عنوان "منتجاتي الأكثر مبيعاً"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'منتجاتي الأكثر مبيعاً',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Text(
                  'اظهر الكل >',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),

            const SizedBox(height: 12),

             // المنتجات
            FutureBuilder<List<ProductCategory>>(
              future: _firebaseService.getCategory(),
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
                        padding: const EdgeInsets.only(right: 12.0),
                        child: CategoryCard(
                          imageUrl: product.imageUrl,// 'lib/assets/images/cucumber.jpg',
                          title: product.name,
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;

  const StatCard({
    required this.title,
    required this.count,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.green),
          const SizedBox(height: 8),
          Text('$count', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String imageUrl;
  final String title;

  const CategoryCard({
    required this.imageUrl,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Image.asset(imageUrl, height: 60, fit: BoxFit.cover),
          const SizedBox(height: 8),
  
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4)
        ],
      ),
    );
  }
}
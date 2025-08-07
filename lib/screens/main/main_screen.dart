import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  // روابط صور من الإنترنت
  final String farmerImage =
      'https://cdn-icons-png.flaticon.com/512/3595/3595455.png';
  final String tomatoImage =
      'https://upload.wikimedia.org/wikipedia/commons/8/89/Tomato_je.jpg';
  final String orangeImage =
      'https://upload.wikimedia.org/wikipedia/commons/c/c4/Orange-Fruit-Pieces.jpg';

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
                      'أهلاً بك!\nادخل منتجاتك وابدأ البيع',
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
                onPressed: () {},
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ProductCard(
                  imageUrl: tomatoImage,
                  title: 'بندورة',
                  rating: 4.7,
                  price: '10000 ليرة',
                ),
                ProductCard(
                  imageUrl: orangeImage,
                  title: 'برتقال',
                  rating: 4.4,
                  price: '12000 ليرة',
                ),
              ],
            )
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

class ProductCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final double rating;
  final String price;

  const ProductCard({
    required this.imageUrl,
    required this.title,
    required this.rating,
    required this.price,
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
          Image.network(imageUrl, height: 60, fit: BoxFit.cover),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.orange, size: 16),
              const SizedBox(width: 4),
              Text(rating.toString()),
            ],
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(price),
          const SizedBox(height: 4),
          const Icon(Icons.add_circle, color: Colors.green),
        ],
      ),
    );
  }
}

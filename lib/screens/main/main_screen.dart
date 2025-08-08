import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../category/choose_category_screen.dart';
import '../../services/firebase_service.dart';

class MainScreen extends StatelessWidget {
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
            // Header Image
            Container(
              constraints: const BoxConstraints(
                minHeight: 150, maxHeight: 200,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: AssetImage('lib/assets/images/farmer_header.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, 
                crossAxisAlignment: CrossAxisAlignment.end,  
                children: const [
                  Text(
                    'أهلاً بك!\nادخل منتجاتك وابدأ البيع',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      height: 1.5,
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
                  Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (context) => ChooseCategoryScreen())
                                        );
                 //() => Navigator.push(context, MaterialPageRoute(builder: (_) =>  ChooseCategoryScreen()));
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
                        padding: const EdgeInsets.only(right: 12.0),
                        child: ProductCard(
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

class ProductCard extends StatelessWidget {
  final String imageUrl;
  final String title;

  const ProductCard({
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
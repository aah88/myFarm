import 'package:flutter/material.dart';
import '../../models/category_model.dart';
import '../../services/firebase_service.dart';
import '../../screens/product/choose_product_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/listing_provider.dart';


class ChooseCategoryScreen extends StatelessWidget {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة منتج', style: TextStyle(color: Color(0xFF2E7D32))),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Color(0xFF2E7D32),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<List<ProductCategory>>(
          future: _firebaseService.getCategory(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('حدث خطأ: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('لا توجد فئات متاحة حالياً.'));
            }

            final categories = snapshot.data!;
            return GridView.builder(
              itemCount: categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              itemBuilder: (context, index) {
                final category = categories[index];
                return CategoryCard(
                  categoryId: category.id,
                  title: category.name,
                  imageUrl: category.imageUrl,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String categoryId;

  const CategoryCard({required this.title, required this.imageUrl, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.read<ListingProvider>().setCategoryId(categoryId);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChooseProductScreen(categoryId: categoryId))
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: Color(0xFF2E7D32), width: 1.5),
          borderRadius: BorderRadius.circular(16)
        ),
        padding: const EdgeInsets.all(0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Image.asset(imageUrl, height: 120, fit: BoxFit.cover),
          const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
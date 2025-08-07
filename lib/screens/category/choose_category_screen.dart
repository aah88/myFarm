import 'package:flutter/material.dart';
import '../../models/category_model.dart';
import '../../services/firebase_service.dart';


class ChooseCategoryScreen extends StatelessWidget {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة منتج', style: TextStyle(color: Colors.green)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
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

  const CategoryCard({required this.title, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // TODO: التنقل أو تنفيذ عملية بناءً على الفئة المختارة
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(),
          borderRadius: BorderRadius.circular(16),
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
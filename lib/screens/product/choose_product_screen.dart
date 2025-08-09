import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../services/firebase_service.dart';
import '../../screens/product/choose_sub_product_screen.dart';

class ChooseProductScreen extends StatelessWidget {
  final FirebaseService _firebaseService = FirebaseService();
  final String categoryId;

  ChooseProductScreen({required this.categoryId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة منتج', style: TextStyle(color: Colors.green)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.green,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<List<Product>>(
          future:  _firebaseService.getProductsByCategory(categoryId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('حدث خطأ: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('لا توجد منتجات متاحة حالياً.'));
            }

            final products = snapshot.data!
                                   .where((product) =>product.parentProduct =="")
                                   .toList();
            return GridView.builder(
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductCard(
                  categoryId: product.id,
                  title: product.name,
                  imageUrl: product.imageUrl,
                  parentProductId: product.id,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String categoryId;
  final String parentProductId;

  const ProductCard({required this.title, required this.imageUrl, required this.categoryId, required this.parentProductId});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
         Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (context) => ChooseSubProductScreen(parentProductId: parentProductId))
                                        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: Colors.green, width: 1.5),
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
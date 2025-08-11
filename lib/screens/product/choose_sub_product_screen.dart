import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../services/firebase_service.dart';
import '../unit/choose_unit_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/listing_provider.dart';
import '../../widgets/product_card.dart';


class ChooseSubProductScreen extends StatelessWidget {
  final FirebaseService _firebaseService = FirebaseService();
  final String parentProductId;

  ChooseSubProductScreen({required this.parentProductId});
  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة منتج', style: TextStyle(color: Color(0xFF2E7D32))),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<List<Product>>(
          future:  _firebaseService.getProductsByProductParent(parentProductId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('حدث خطأ: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('لا توجد منتجات متاحة حالياً.'));
            }

            final products = snapshot.data!;
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
                  categoryId: product.category.id,
                  title: product.name,
                  parentProductId: product.id ,
                  imageUrl: product.imageUrl,
                  onTap: () {
                    context.read<ListingProvider>().setProductId(product.category.id);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChooseUnitScreen())
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
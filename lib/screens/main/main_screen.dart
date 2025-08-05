import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../services/firebase_service.dart';


class MainScreen extends StatelessWidget {
  final FirebaseService _firebaseService = FirebaseService();
  late Future<List<Product>> _productsFuture = _firebaseService.getProducts();
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Products")),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No products found"));
          }

          final products = snapshot.data!;

          return GridView.builder(
            padding: EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 columns
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 3 / 4,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ElevatedButton(
                onPressed: () {
                  // Handle tap
                  print('Selected: ${product.name}');
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.white,
                  elevation: 4,
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Image.network(
                        //product.imageUrl,
                        'https://cdn-ilbieip.nitrocdn.com/xqwDdPehmVtcySpgjQnaFLFbBZtNqOso/assets/images/optimized/rev-1562a4e/www.harvst.co.uk/wp-content/uploads/2022/04/cucumbers-scaled.jpeg',
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        product.name,
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

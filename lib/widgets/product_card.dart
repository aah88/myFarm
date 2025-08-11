import 'package:flutter/material.dart';
import '../../screens/product/choose_sub_product_screen.dart';

/// Product card inside the grid
class ProductCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String categoryId;
  final String parentProductId;

  const ProductCard({
    required this.title,
    required this.imageUrl,
    required this.categoryId,
    required this.parentProductId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // Navigate to sub-product screen
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ChooseSubProductScreen(parentProductId: parentProductId),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color(0xFFE8EBE6), // Same border as letters
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03), // Light shadow
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Product image (full image without cropping)
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  imageUrl,
                  fit: BoxFit.contain, // Show full image without cropping
                  width: double.infinity,
                ),
              ),
            ),
            const SizedBox(height: 6),
            // Product title
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF70756B),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
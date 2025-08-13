import 'package:flutter/material.dart';

/// Product card inside the grid
class ProductCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String categoryId;
  final String parentProductId;
  final VoidCallback? onTap;

  const ProductCard({
    required this.title,
    required this.imageUrl,
    required this.categoryId,
    required this.parentProductId,
    this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // Navigate to sub-product screen
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE8EBE6)),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 6))],
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
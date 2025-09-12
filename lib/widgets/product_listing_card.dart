import 'package:flutter/material.dart';
import '../../config/app_config.dart';

class ProductListingCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final double rating;
  final double price;
  final String farmerName;
  final double distance;
  final VoidCallback onAddToCart;

  const ProductListingCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.rating,
    required this.price,
    required this.farmerName,
    required this.distance,
    required this.onAddToCart,
  });

  bool get _isNetwork => imageUrl.startsWith('http');

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // RTL للغة العربية
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE7EAE5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ====== صورة المنتج ======
              Expanded(
                child: Center(
                  child: _isNetwork
                      ? Image.network(imageUrl, fit: BoxFit.contain)
                      : Image.asset(imageUrl, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 8),

              // ====== التقييم ======
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, size: 16, color: Color(0xFFFFC107)),
                  const SizedBox(width: 4),
                  Text(
                    rating.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // ====== اسم المنتج ======
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),

              // ====== السعر + زر الإضافة ======
              Row(
                children: [
                  Text(
                    AppConfig.formatPrice(price),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: Material(
                      color: const Color(0x1A2E7D32),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: onAddToCart,
                        child: const Center(
                          child: Icon(Icons.add, color: Color(0xFF2E7D32)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // ====== معلومات إضافية ======
              const SizedBox(height: 6),
              Text(
                'من $farmerName · ${AppConfig.formatDistance(distance)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.black.withOpacity(.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

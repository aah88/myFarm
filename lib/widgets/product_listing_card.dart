import 'package:flutter/material.dart';
import 'package:flutter_application_1/theme/design_tokens.dart';
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
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE8EBE6)),
          borderRadius: BorderRadius.circular(8),
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
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ====== صورة المنتج + التقييم فوقها ======
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: _isNetwork
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.contain,
                              width: double.infinity,
                            )
                          : Image.asset(
                              imageUrl,
                              fit: BoxFit.contain,
                              width: double.infinity,
                            ),
                    ),
                    // بادج التقييم
                    Positioned(
                      bottom: 5,
                      left: 8, 
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, size: 16, color: Color(0xFFFFC107)),
                            const SizedBox(width: 4),
                            Text(
                              rating.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              // ====== اسم المنتج ======
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  title,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF70756B),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // ====== السعر + زر الإضافة ======
              Row(
                children: [
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: Material(
                      color: AppColors.gray100,                
                      shape: CircleBorder(
                        side: BorderSide(
                          color: AppColors.gray200, // لون الحد
                          width: 1,                 // سماكة الحد
                        ),
                      ),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: onAddToCart,
                        child: const Center(
                          child: Icon(Icons.add, color: AppColors.green),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    AppConfig.formatPrice(price),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

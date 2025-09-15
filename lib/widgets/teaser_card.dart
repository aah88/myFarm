import 'package:flutter/material.dart';
import 'package:flutter_application_1/theme/design_tokens.dart';

/// Teaser: صورة على اليمين + جراديانت ونص على اليسار (بدون أي زخارف)
class TeaserCard extends StatelessWidget {
  const TeaserCard({
    super.key,
    this.leftTitle = 'Experience our\ndelicious new dish',
    this.leftBigText = '20% OFF',
    required this.rightImage,
    this.leftStart = AppColors.green,
    this.leftEnd   = AppColors.green,
    this.height = 150,
    this.onTap,
  });

  final String leftTitle;
  final String leftBigText;
  final ImageProvider rightImage;
  final Color leftStart, leftEnd;
  final double height;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.gray100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.gray200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            // ===== اليسار: جراديانت + نصوص (بدون دوائر) =====
            Expanded(
              flex: 11,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [leftStart, leftEnd],
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      leftTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      leftBigText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 8),

            // ===== اليمين: الصورة فقط =====
            Expanded(
              flex: 8,
              child: Container(
                padding: const EdgeInsets.all(10),
                alignment: Alignment.center,
                child: AspectRatio(
                  aspectRatio: 1.5, // عدّلها حسب رسمك
                  child: Image(image: rightImage, fit: BoxFit.contain),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
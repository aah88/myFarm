// lib/theme/design_tokens.dart
import 'package:flutter/material.dart';

/// سُلَّم المسافات (8px scale)
class Spacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

/// أنصاف الأقطار
class Radii {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
}

/// ألوان العلامة
class BrandColors {
  static const Color green = Color(0xFF2E7D32);
  static const Color greenSoft = Color(0xFFECF1E8);
  static const Color gray100 = Color(0xFFF7F8F6);
  static const Color gray200 = Color(0xFFE8EBE6);
  static const Color gray400 = Color(0xFFB6BAB5);
  static const Color text = Colors.black87;
  static const Color danger = Color(0xFFE95322);
  static const Color white = Colors.white;
}

/// ظلال
class Shadows {
  static List<BoxShadow> cardSm = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> cardXs = [
    BoxShadow(
      color: Colors.black.withOpacity(0.03),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];
}

/// حدود وحواف
class Borders {
  static BorderSide thin = const BorderSide(color: BrandColors.gray200, width: 1);
  static BorderRadius rSm = BorderRadius.circular(Radii.sm);
  static BorderRadius rMd = BorderRadius.circular(Radii.md);
}

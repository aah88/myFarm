// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'design_tokens.dart';

class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: BrandColors.green,
      brightness: Brightness.light,
    );

    final baseText = GoogleFonts.tajawalTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: BrandColors.white,
      splashFactory: InkSparkle.splashFactory,

      // نصوص
      textTheme: baseText.apply(
        bodyColor: BrandColors.text,
        displayColor: BrandColors.text,
      ),

      // 👇 AppBar (لو حاب تخصيص مختلف لأيقونات الشريط)
      appBarTheme: const AppBarTheme(
        backgroundColor: BrandColors.white,
        foregroundColor: BrandColors.text,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(size: 22, color: BrandColors.text),
      ),

      // 👇 هذا هو الموضع الوحيد لـ iconTheme (لا تكرّره)
      iconTheme: const IconThemeData(size: 22, color: BrandColors.green),

      dividerTheme: const DividerThemeData(
        color: BrandColors.gray200,
        thickness: 1,
        space: 1,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: BrandColors.green,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: Borders.rSm),
          // ⬇️ خط أصغر ومتناسق
          textStyle: const TextStyle(
            fontSize: 14,           // كان 15-16
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          side: const BorderSide(color: BrandColors.gray200, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: Borders.rSm),
          foregroundColor: BrandColors.text,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          foregroundColor: BrandColors.danger,
          textStyle: const TextStyle(
            fontSize: 13,           // أصغر قليلًا للـ text buttons
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
      ),

      cardTheme: CardThemeData(
        color: BrandColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: Borders.rSm,
          side: Borders.thin,
        ),
        shadowColor: Colors.black.withOpacity(0.05),
        margin: EdgeInsets.zero,
      ),

      inputDecorationTheme: InputDecorationTheme(
        labelStyle: const TextStyle(
          color: Color(0xFF91958E),
        fontWeight: FontWeight.bold,
        ),
        hintStyle: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFE8EBE6), width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}

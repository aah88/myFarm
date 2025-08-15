class AppConfig {
  static const String currencySymbol = "ل.س"; // Syrian Pound
  static const String currencyCode = "SYP";   // ISO code

  /// Helper to format prices with currency
  static String formatPrice(double value) {
    return "${value.toStringAsFixed(0)} $currencySymbol";
  }
}
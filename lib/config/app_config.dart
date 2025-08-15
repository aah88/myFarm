class AppConfig {
  static const String currencySymbol = "ل.س"; // Syrian Pound
  static const String currencyCode = "SYP";   // ISO code
  static const String distanceUnit = "كم";

  /// Helper to format prices with currency
  static String formatPrice(double value) {
    return "${value.toStringAsFixed(0)} $currencySymbol";
  }
  static String formatDistance(double value) {
    return "${value.toStringAsFixed(0)} $distanceUnit";
  }
}
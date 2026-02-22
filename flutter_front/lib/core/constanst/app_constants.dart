class AppConstants {
  // API / Backend (SQLite দিয়ে করলে baseUrl লাগবে না, তাই কমেন্ট করে রাখলাম)
  // static const String baseUrl = "http://192.168.1.x:8080/api";

  // Currency
  static const String currencySymbol =
      "৳"; // তোমার চাওয়া অনুযায়ী বাংলাদেশী টাকা

  // Shared Preferences keys (SQLite + shared prefs মিক্স করলে লাগবে)
  static const String prefAuthToken = "auth_token";
  static const String prefUserId = "user_id";
  static const String prefCartItems = "cart_items";

  // App info
  static const String appVersion = "1.0.0";
  static const int maxCartItems = 50;

  // Animation durations
  static const Duration defaultAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 600);

  // Pagination / lists
  static const int defaultPageSize = 20;
}

class AppConstants {
  static const String appName = 'CurrencyX';
  static const int cacheTTLMinutes = 30;
  static const int maxRecentPairs = 5;
  
  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 800);
  
  // Cache keys
  static const String recentPairsKey = 'recent_pairs';
  static const String conversionCachePrefix = 'conversion_';
  static const String lastUserKey = 'last_user';
}
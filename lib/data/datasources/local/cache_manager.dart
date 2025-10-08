import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';

class CacheManager {
  final SharedPreferences sharedPreferences;

  CacheManager(this.sharedPreferences);

  Future<void> cacheConversion({
    required String from,
    required String to,
    required double amount,
    required Map<String, dynamic> data,
  }) async {
    final key = '${AppConstants.conversionCachePrefix}${from}_${to}_$amount';
    final cacheData = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await sharedPreferences.setString(key, jsonEncode(cacheData));
  }

  Map<String, dynamic>? getCachedConversion({
    required String from,
    required String to,
    required double amount,
  }) {
    final key = '${AppConstants.conversionCachePrefix}${from}_${to}_$amount';
    final cached = sharedPreferences.getString(key);
    
    if (cached == null) return null;
    
    final cacheData = jsonDecode(cached);
    final timestamp = cacheData['timestamp'] as int;
    final now = DateTime.now().millisecondsSinceEpoch;
    final diffMinutes = (now - timestamp) / (1000 * 60);
    
    if (diffMinutes > AppConstants.cacheTTLMinutes) {
      return null; // Cache expired
    }
    
    return cacheData['data'];
  }

  Future<void> saveRecentPair(String from, String to) async {
    final recentPairs = getRecentPairs();
    final pair = '$from-$to';
    
    recentPairs.remove(pair);
    recentPairs.insert(0, pair);
    
    if (recentPairs.length > AppConstants.maxRecentPairs) {
      recentPairs.removeRange(AppConstants.maxRecentPairs, recentPairs.length);
    }
    
    await sharedPreferences.setStringList(AppConstants.recentPairsKey, recentPairs);
  }

  List<String> getRecentPairs() {
    return sharedPreferences.getStringList(AppConstants.recentPairsKey) ?? [];
  }
}
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';

class CacheManager {
  final SharedPreferences sharedPreferences;

  CacheManager(this.sharedPreferences);

  // Cache conversion with amount
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
      'amount': amount,
    };
    await sharedPreferences.setString(key, jsonEncode(cacheData));
    
    // Also cache the last conversion for this pair (regardless of amount)
    await _cacheLastConversionForPair(from, to, amount, data);
  }

  // NEW: Cache last conversion for a currency pair
  Future<void> _cacheLastConversionForPair(
    String from,
    String to,
    double amount,
    Map<String, dynamic> data,
  ) async {
    final key = 'last_conversion_${from}_$to';
    final cacheData = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'amount': amount,
    };
    await sharedPreferences.setString(key, jsonEncode(cacheData));
  }

  // Get cached conversion with specific amount
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

  // NEW: Get last conversion for a pair (any amount)
  Map<String, dynamic>? getLastConversionForPair({
    required String from,
    required String to,
  }) {
    final key = 'last_conversion_${from}_$to';
    final cached = sharedPreferences.getString(key);
    
    if (cached == null) return null;
    
    final cacheData = jsonDecode(cached);
    final timestamp = cacheData['timestamp'] as int;
    final now = DateTime.now().millisecondsSinceEpoch;
    final diffMinutes = (now - timestamp) / (1000 * 60);
    
    if (diffMinutes > AppConstants.cacheTTLMinutes) {
      return null; // Cache expired
    }
    
    return {
      'data': cacheData['data'],
      'amount': cacheData['amount'],
    };
  }

  // NEW: Get the last amount used for a pair
  double? getLastAmountForPair(String from, String to) {
    final key = 'last_conversion_${from}_$to';
    final cached = sharedPreferences.getString(key);
    
    if (cached == null) return null;
    
    final cacheData = jsonDecode(cached);
    return (cacheData['amount'] as num?)?.toDouble();
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

  // NEW: Get recent pairs with their cached amounts
  List<Map<String, dynamic>> getRecentPairsWithData() {
    final pairs = getRecentPairs();
    return pairs.map((pair) {
      final parts = pair.split('-');
      final from = parts[0];
      final to = parts[1];
      final lastData = getLastConversionForPair(from: from, to: to);
      
      return {
        'from': from,
        'to': to,
        'amount': lastData?['amount'] ?? 100.0,
        'hasCache': lastData != null,
      };
    }).toList();
  }
}
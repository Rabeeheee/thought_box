import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';

class CacheManager {
  final SharedPreferences sharedPreferences;

  CacheManager(this.sharedPreferences);

  Future<void> clearAllConversionCache() async {
    final keys = sharedPreferences.getKeys();
    final keysToRemove = keys.where((key) =>
        key.startsWith(AppConstants.conversionCachePrefix) ||
        key.startsWith('last_conversion_'));

    for (final key in keysToRemove) {
      await sharedPreferences.remove(key);
    }

  }

  Future<void> clearRecentPairs() async {
    await sharedPreferences.remove(AppConstants.recentPairsKey);
  }

  Future<void> clearAllCache() async {
    await clearAllConversionCache();
    await clearRecentPairs();
  }

  Future<void> clearExpiredCache() async {
    final keys = sharedPreferences.getKeys();
    // ignore: unused_local_variable
    int expiredCount = 0;

    for (final key in keys) {
      if (key.startsWith(AppConstants.conversionCachePrefix) ||
          key.startsWith('last_conversion_')) {
        final cached = sharedPreferences.getString(key);
        if (cached != null) {
          try {
            final cacheData = jsonDecode(cached);
            final timestamp = cacheData['timestamp'] as int;
            final now = DateTime.now().millisecondsSinceEpoch;
            final diffMinutes = (now - timestamp) / (1000 * 60);

            if (diffMinutes > AppConstants.cacheTTLMinutes) {
              await sharedPreferences.remove(key);
              expiredCount++;
            }
          } catch (e) {
            // Invalid cache data, remove it
            await sharedPreferences.remove(key);
            expiredCount++;
          }
        }
      }
    }

  }

  Map<String, dynamic> getCacheInfo() {
    final keys = sharedPreferences.getKeys();
    int totalCached = 0;
    int expiredCached = 0;
    int validCached = 0;

    for (final key in keys) {
      if (key.startsWith(AppConstants.conversionCachePrefix) ||
          key.startsWith('last_conversion_')) {
        totalCached++;

        final cached = sharedPreferences.getString(key);
        if (cached != null) {
          try {
            final cacheData = jsonDecode(cached);
            final timestamp = cacheData['timestamp'] as int;
            final now = DateTime.now().millisecondsSinceEpoch;
            final diffMinutes = (now - timestamp) / (1000 * 60);

            if (diffMinutes > AppConstants.cacheTTLMinutes) {
              expiredCached++;
            } else {
              validCached++;
            }
          } catch (e) {
            expiredCached++;
          }
        }
      }
    }

    return {
      'total': totalCached,
      'valid': validCached,
      'expired': expiredCached,
    };
  }

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
    await _cacheLastConversionForPair(from, to, amount, data);
  }

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
      return null;
    }

    return cacheData['data'];
  }

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
      return null;
    }

    return {
      'data': cacheData['data'],
      'amount': cacheData['amount'],
    };
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
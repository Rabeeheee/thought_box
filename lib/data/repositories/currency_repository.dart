import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../data/models/conversion_response.dart';

abstract class CurrencyRepository {
  Future<Either<Failure, ConversionResponse>> convertCurrency({
    required String from,
    required String to,
    required double amount,
  });
  
  // NEW: Get cached conversion for recent pair
  Either<Failure, ConversionResponse>? getCachedConversionForPair({
    required String from,
    required String to,
  });
  
  List<String> getRecentPairs();
  
  // NEW: Get recent pairs with data
  List<Map<String, dynamic>> getRecentPairsWithData();
}
import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../data/models/conversion_response.dart';

abstract class CurrencyRepository {
  Future<Either<Failure, ConversionResponse>> convertCurrency({
    required String from,
    required String to,
    required double amount,
  });
  
  List<String> getRecentPairs();
}
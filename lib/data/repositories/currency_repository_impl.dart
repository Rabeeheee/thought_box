import 'package:dartz/dartz.dart';
import 'package:thought_box/data/repositories/currency_repository.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../datasources/local/cache_manager.dart';
import '../datasources/remote/currency_api.dart';
import '../models/conversion_response.dart';

class CurrencyRepositoryImpl implements CurrencyRepository {
  final CurrencyApi currencyApi;
  final CacheManager cacheManager;

  CurrencyRepositoryImpl({
    required this.currencyApi,
    required this.cacheManager,
  });

  @override
  Future<Either<Failure, ConversionResponse>> convertCurrency({
    required String from,
    required String to,
    required double amount,
  }) async {
    try {
      // Try cache first
      final cached = cacheManager.getCachedConversion(
        from: from,
        to: to,
        amount: amount,
      );
      
      if (cached != null) {
        return Right(ConversionResponse.fromJson(cached));
      }

      // Fetch from API=--=
      final response = await currencyApi.convertCurrency(
        from: from,
        to: to,
        amount: amount,
      );

      // Cache the response---
      await cacheManager.cacheConversion(
        from: from,
        to: to,
        amount: amount,
        data: response.toJson(),
      );

      // Save to recent pairs==
      await cacheManager.saveRecentPair(from, to);

      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  List<String> getRecentPairs() {
    return cacheManager.getRecentPairs();
  }
}
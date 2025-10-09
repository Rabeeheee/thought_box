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
      // TRY CACHE FIRST
      final cached = cacheManager.getCachedConversion(
        from: from,
        to: to,
        amount: amount,
      );
      
      if (cached != null) {
        return Right(ConversionResponse.fromJson(cached));
      }

      
      // FETCH FROM API
      final response = await currencyApi.convertCurrency(
        from: from,
        to: to,
        amount: amount,
      );

      await cacheManager.cacheConversion(
        from: from,
        to: to,
        amount: amount,
        data: response.toJson(),
      );

      // SAVE to recennt 
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
  Either<Failure, ConversionResponse>? getCachedConversionForPair({
    required String from,
    required String to,
  }) {
    try {
      final lastData = cacheManager.getLastConversionForPair(
        from: from,
        to: to,
      );
      
      if (lastData != null) {
        return Right(ConversionResponse.fromJson(lastData['data']));
      }
      
      return null;
    } catch (e) {
      return Left(CacheFailure('Failed to load cached data'));
    }
  }

  @override
  List<String> getRecentPairs() {
    return cacheManager.getRecentPairs();
  }

  @override
  List<Map<String, dynamic>> getRecentPairsWithData() {
    return cacheManager.getRecentPairsWithData();
  }
}
import 'package:dio/dio.dart';
import 'package:thought_box/core/error/exceptions.dart';
import '../../../core/config/env_config.dart';
import '../../../core/network/api_client.dart';
import '../../models/conversion_response.dart';

class CurrencyApi {
  final ApiClient apiClient;

  CurrencyApi(this.apiClient);

  Future<ConversionResponse> convertCurrency({
    required String from,
    required String to,
    required double amount,
  }) async {
    try {
      if (EnvConfig.useMockData) {
        await Future.delayed(const Duration(seconds: 1));
        return _getMockResponse(from, to, amount);
      }

      final response = await apiClient.dio.get(
        '/convert',
        queryParameters: {
          'from': from,
          'to': to,
          'amount': amount.toString(),
        },
      );

      if (response.statusCode == 200) {
        return ConversionResponse.fromJson(response.data);
      } else {
        throw ServerException('Failed to convert currency');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException(e.message ?? 'Server error');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  ConversionResponse _getMockResponse(String from, String to, double amount) {
    final mockRate = 1.5 + (from.hashCode % 10) / 10;
    return ConversionResponse(
      base: from,
      amount: amount.toString(),
      result: ConversionResult(
        rate: mockRate,
        convertedAmount: amount * mockRate,
        toCurrency: to,
      ),
      ms: 120,
    );
  }
}
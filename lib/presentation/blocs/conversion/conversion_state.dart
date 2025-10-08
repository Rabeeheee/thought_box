import 'package:equatable/equatable.dart';
import '../../../data/models/conversion_response.dart';

abstract class ConversionState extends Equatable {
  final String fromCurrency;
  final String toCurrency;

  const ConversionState({
    this.fromCurrency = 'USD',
    this.toCurrency = 'EUR',
  });

  @override
  List<Object?> get props => [fromCurrency, toCurrency];
}

class ConversionInitial extends ConversionState {
  const ConversionInitial({
    super.fromCurrency,
    super.toCurrency,
  });
}

class ConversionLoading extends ConversionState {
  const ConversionLoading({
    required super.fromCurrency,
    required super.toCurrency,
  });
}

class ConversionSuccess extends ConversionState {
  final ConversionResponse response;
  final List<String> recentPairs;

  const ConversionSuccess({
    required this.response,
    this.recentPairs = const [],
    required super.fromCurrency,
    required super.toCurrency,
  });

  @override
  List<Object?> get props => [response, recentPairs, fromCurrency, toCurrency];
}

class ConversionError extends ConversionState {
  final String message;

  const ConversionError(
    this.message, {
    required super.fromCurrency,
    required super.toCurrency,
  });

  @override
  List<Object?> get props => [message, fromCurrency, toCurrency];
}

class ConversionWithRecent extends ConversionState {
  final List<String> recentPairs;

  const ConversionWithRecent(
    this.recentPairs, {
    required super.fromCurrency,
    required super.toCurrency,
  });

  @override
  List<Object?> get props => [recentPairs, fromCurrency, toCurrency];
}
import 'package:equatable/equatable.dart';

abstract class ConversionEvent extends Equatable {
  const ConversionEvent();

  @override
  List<Object> get props => [];
}

class ConvertCurrencyRequested extends ConversionEvent {
  final String from;
  final String to;
  final double amount;

  const ConvertCurrencyRequested({
    required this.from,
    required this.to,
    required this.amount,
  });

  @override
  List<Object> get props => [from, to, amount];
}

class SwapCurrenciesRequested extends ConversionEvent {
  final String from;
  final String to;
  final double amount;

  const SwapCurrenciesRequested({
    required this.from,
    required this.to,
    required this.amount,
  });

  @override
  List<Object> get props => [from, to, amount];
}

class LoadRecentPairs extends ConversionEvent {}

class CurrencySelected extends ConversionEvent {
  final String currencyCode;
  final bool isFrom;

  const CurrencySelected({
    required this.currencyCode,
    required this.isFrom,
  });

  @override
  List<Object> get props => [currencyCode, isFrom];
}

class CurrenciesSwapped extends ConversionEvent {
  const CurrenciesSwapped();
}

// NEW: Load cached conversion from recent pair
class RecentPairSelected extends ConversionEvent {
  final String from;
  final String to;

  const RecentPairSelected({
    required this.from,
    required this.to,
  });

  @override
  List<Object> get props => [from, to];
}
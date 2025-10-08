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

// NEW EVENTS
class FromCurrencyChanged extends ConversionEvent {
  final String currencyCode;

  const FromCurrencyChanged(this.currencyCode);

  @override
  List<Object> get props => [currencyCode];
}

class ToCurrencyChanged extends ConversionEvent {
  final String currencyCode;

  const ToCurrencyChanged(this.currencyCode);

  @override
  List<Object> get props => [currencyCode];
}

class CurrenciesSwapped extends ConversionEvent {}

class RecentPairSelected extends ConversionEvent {
  final String from;
  final String to;
  final double amount;

  const RecentPairSelected({
    required this.from,
    required this.to,
    required this.amount,
  });

  @override
  List<Object> get props => [from, to, amount];
}
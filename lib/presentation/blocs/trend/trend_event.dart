import 'package:equatable/equatable.dart';

abstract class TrendEvent extends Equatable {
  const TrendEvent();

  @override
  List<Object?> get props => [];
}

class TrendInitialized extends TrendEvent {
  final String fromCurrency;
  final String toCurrency;

  const TrendInitialized({
    required this.fromCurrency,
    required this.toCurrency,
  });

  @override
  List<Object?> get props => [fromCurrency, toCurrency];
}

class TrendPointSelected extends TrendEvent {
  final int? index;

  const TrendPointSelected(this.index);

  @override
  List<Object?> get props => [index];
}
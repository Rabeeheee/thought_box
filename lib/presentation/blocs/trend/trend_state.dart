import 'package:equatable/equatable.dart';
import 'package:fl_chart/fl_chart.dart';

abstract class TrendState extends Equatable {
  final List<FlSpot> spots;
  final List<String> dates;
  final double minRate;
  final double maxRate;
  final double avgRate;
  final int? selectedIndex;

  const TrendState({
    required this.spots,
    required this.dates,
    required this.minRate,
    required this.maxRate,
    required this.avgRate,
    this.selectedIndex,
  });

  @override
  List<Object?> get props => [spots, dates, minRate, maxRate, avgRate, selectedIndex];
}

class TrendInitial extends TrendState {
  const TrendInitial({
    required super.spots,
    required super.dates,
    required super.minRate,
    required super.maxRate,
    required super.avgRate,
    super.selectedIndex,
  });
}

class TrendLoaded extends TrendState {
  const TrendLoaded({
    required super.spots,
    required super.dates,
    required super.minRate,
    required super.maxRate,
    required super.avgRate,
    super.selectedIndex,
  });
}
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'trend_event.dart';
import 'trend_state.dart';

class TrendBloc extends Bloc<TrendEvent, TrendState> {
  TrendBloc()
      : super(const TrendInitial(
          spots: [],
          dates: [],
          minRate: 0,
          maxRate: 0,
          avgRate: 0,
        )) {
    on<TrendInitialized>(_onInitialized);
    on<TrendPointSelected>(_onPointSelected);
  }

  void _onInitialized(
    TrendInitialized event,
    Emitter<TrendState> emit,
  ) {
    // Generate mock data
    final baseRate = 1.5 + (event.fromCurrency.hashCode % 10) / 10;
    final spots = List.generate(5, (index) {
      final variation = (index - 2) * 0.05;
      return FlSpot(index.toDouble(), baseRate + variation);
    });

    final dates = List.generate(5, (index) {
      final date = DateTime.now().subtract(Duration(days: 4 - index));
      return DateFormat('MMM dd').format(date);
    });

    final rates = spots.map((spot) => spot.y).toList();
    final minRate = rates.reduce((a, b) => a < b ? a : b);
    final maxRate = rates.reduce((a, b) => a > b ? a : b);
    final avgRate = rates.reduce((a, b) => a + b) / rates.length;

    emit(TrendLoaded(
      spots: spots,
      dates: dates,
      minRate: minRate,
      maxRate: maxRate,
      avgRate: avgRate,
    ));
  }

  void _onPointSelected(
    TrendPointSelected event,
    Emitter<TrendState> emit,
  ) {
    if (state is TrendLoaded) {
      final currentState = state as TrendLoaded;
      emit(TrendLoaded(
        spots: currentState.spots,
        dates: currentState.dates,
        minRate: currentState.minRate,
        maxRate: currentState.maxRate,
        avgRate: currentState.avgRate,
        selectedIndex: event.index,
      ));
    }
  }
}
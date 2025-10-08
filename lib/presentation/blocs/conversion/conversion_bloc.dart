import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thought_box/data/repositories/currency_repository.dart';
import 'conversion_event.dart';
import 'conversion_state.dart';

class ConversionBloc extends Bloc<ConversionEvent, ConversionState> {
  final CurrencyRepository currencyRepository;

  ConversionBloc(this.currencyRepository) : super(const ConversionInitial()) {
    on<ConvertCurrencyRequested>(_onConvertRequested);
    on<SwapCurrenciesRequested>(_onSwapRequested);
    on<LoadRecentPairs>(_onLoadRecentPairs);
    on<CurrencySelected>(_onCurrencySelected);
    on<CurrenciesSwapped>(_onCurrenciesSwapped);
  }

  Future<void> _onConvertRequested(
    ConvertCurrencyRequested event,
    Emitter<ConversionState> emit,
  ) async {
    emit(ConversionLoading(
      fromCurrency: event.from,
      toCurrency: event.to,
    ));

    final result = await currencyRepository.convertCurrency(
      from: event.from,
      to: event.to,
      amount: event.amount,
    );

    result.fold(
      (failure) => emit(ConversionError(
        failure.message,
        fromCurrency: event.from,
        toCurrency: event.to,
      )),
      (response) {
        final recentPairs = currencyRepository.getRecentPairs();
        emit(ConversionSuccess(
          response: response,
          recentPairs: recentPairs,
          fromCurrency: event.from,
          toCurrency: event.to,
        ));
      },
    );
  }

  Future<void> _onSwapRequested(
    SwapCurrenciesRequested event,
    Emitter<ConversionState> emit,
  ) async {
    emit(ConversionLoading(
      fromCurrency: event.to,
      toCurrency: event.from,
    ));

    final result = await currencyRepository.convertCurrency(
      from: event.to,
      to: event.from,
      amount: event.amount,
    );

    result.fold(
      (failure) => emit(ConversionError(
        failure.message,
        fromCurrency: event.to,
        toCurrency: event.from,
      )),
      (response) {
        final recentPairs = currencyRepository.getRecentPairs();
        emit(ConversionSuccess(
          response: response,
          recentPairs: recentPairs,
          fromCurrency: event.to,
          toCurrency: event.from,
        ));
      },
    );
  }

  void _onLoadRecentPairs(
    LoadRecentPairs event,
    Emitter<ConversionState> emit,
  ) {
    final recentPairs = currencyRepository.getRecentPairs();
    emit(ConversionWithRecent(
      recentPairs,
      fromCurrency: state.fromCurrency,
      toCurrency: state.toCurrency,
    ));
  }

  void _onCurrencySelected(
    CurrencySelected event,
    Emitter<ConversionState> emit,
  ) {
    final newFrom = event.isFrom ? event.currencyCode : state.fromCurrency;
    final newTo = event.isFrom ? state.toCurrency : event.currencyCode;

    if (state is ConversionSuccess) {
      final currentState = state as ConversionSuccess;
      emit(ConversionSuccess(
        response: currentState.response,
        recentPairs: currentState.recentPairs,
        fromCurrency: newFrom,
        toCurrency: newTo,
      ));
    } else if (state is ConversionWithRecent) {
      final currentState = state as ConversionWithRecent;
      emit(ConversionWithRecent(
        currentState.recentPairs,
        fromCurrency: newFrom,
        toCurrency: newTo,
      ));
    } else {
      emit(ConversionInitial(
        fromCurrency: newFrom,
        toCurrency: newTo,
      ));
    }
  }

  void _onCurrenciesSwapped(
    CurrenciesSwapped event,
    Emitter<ConversionState> emit,
  ) {
    if (state is ConversionSuccess) {
      final currentState = state as ConversionSuccess;
      emit(ConversionSuccess(
        response: currentState.response,
        recentPairs: currentState.recentPairs,
        fromCurrency: state.toCurrency,
        toCurrency: state.fromCurrency,
      ));
    } else if (state is ConversionWithRecent) {
      final currentState = state as ConversionWithRecent;
      emit(ConversionWithRecent(
        currentState.recentPairs,
        fromCurrency: state.toCurrency,
        toCurrency: state.fromCurrency,
      ));
    } else {
      emit(ConversionInitial(
        fromCurrency: state.toCurrency,
        toCurrency: state.fromCurrency,
      ));
    }
  }
}
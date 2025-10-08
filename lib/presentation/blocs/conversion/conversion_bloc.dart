import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thought_box/data/repositories/currency_repository.dart';
import 'conversion_event.dart';
import 'conversion_state.dart';

class ConversionBloc extends Bloc<ConversionEvent, ConversionState> {
  final CurrencyRepository currencyRepository;

  ConversionBloc(this.currencyRepository) : super(ConversionInitial()) {
    on<ConvertCurrencyRequested>(_onConvertRequested);
    on<SwapCurrenciesRequested>(_onSwapRequested);
    on<LoadRecentPairs>(_onLoadRecentPairs);
  }

  Future<void> _onConvertRequested(
    ConvertCurrencyRequested event,
    Emitter<ConversionState> emit,
  ) async {
    emit(ConversionLoading());
    
    final result = await currencyRepository.convertCurrency(
      from: event.from,
      to: event.to,
      amount: event.amount,
    );

    result.fold(
      (failure) => emit(ConversionError(failure.message)),
      (response) {
        final recentPairs = currencyRepository.getRecentPairs();
        emit(ConversionSuccess(
          response: response,
          recentPairs: recentPairs,
        ));
      },
    );
  }

  Future<void> _onSwapRequested(
    SwapCurrenciesRequested event,
    Emitter<ConversionState> emit,
  ) async {
    emit(ConversionLoading());
    
    final result = await currencyRepository.convertCurrency(
      from: event.to,
      to: event.from,
      amount: event.amount,
    );

    result.fold(
      (failure) => emit(ConversionError(failure.message)),
      (response) {
        final recentPairs = currencyRepository.getRecentPairs();
        emit(ConversionSuccess(
          response: response,
          recentPairs: recentPairs,
        ));
      },
    );
  }

  void _onLoadRecentPairs(
    LoadRecentPairs event,
    Emitter<ConversionState> emit,
  ) {
    final recentPairs = currencyRepository.getRecentPairs();
    emit(ConversionWithRecent(recentPairs));
  }
}
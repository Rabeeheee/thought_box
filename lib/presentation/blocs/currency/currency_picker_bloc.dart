import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/currency_data.dart';
import '../../../data/models/currency_model.dart';
import 'currency_picker_event.dart';
import 'currency_picker_state.dart';

class CurrencyPickerBloc extends Bloc<CurrencyPickerEvent, CurrencyPickerState> {
  final List<CurrencyModel> _allCurrencies;

  CurrencyPickerBloc()
      : _allCurrencies = CurrencyData.currencyCodes
            .map((code) => CurrencyModel.fromCode(code))
            .toList(),
        super(CurrencyPickerInitial(
          filteredCurrencies: CurrencyData.currencyCodes
              .map((code) => CurrencyModel.fromCode(code))
              .toList(),
        )) {
    on<CurrencyPickerInitialized>(_onInitialized);
    on<SearchQueryChanged>(_onSearchQueryChanged);
  }

  void _onInitialized(
    CurrencyPickerInitialized event,
    Emitter<CurrencyPickerState> emit,
  ) {
    emit(CurrencyPickerInitial(
      filteredCurrencies: _allCurrencies,
    ));
  }

  void _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<CurrencyPickerState> emit,
  ) {
    final query = event.query.toLowerCase();

    if (query.isEmpty) {
      emit(CurrencyPickerSearching(
        filteredCurrencies: _allCurrencies,
        searchQuery: query,
      ));
    } else {
      final filtered = _allCurrencies.where((currency) {
        return currency.code.toLowerCase().contains(query) ||
            currency.name.toLowerCase().contains(query);
      }).toList();

      emit(CurrencyPickerSearching(
        filteredCurrencies: filtered,
        searchQuery: query,
      ));
    }
  }
}
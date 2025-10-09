import 'package:equatable/equatable.dart';
import '../../../data/models/currency_model.dart';

abstract class CurrencyPickerState extends Equatable {
  final List<CurrencyModel> filteredCurrencies;
  final String searchQuery;

  const CurrencyPickerState({
    required this.filteredCurrencies,
    this.searchQuery = '',
  });

  @override
  List<Object> get props => [filteredCurrencies, searchQuery];
}

class CurrencyPickerInitial extends CurrencyPickerState {
  const CurrencyPickerInitial({
    required super.filteredCurrencies,
    super.searchQuery,
  });
}

 class CurrencyPickerSearching extends CurrencyPickerState {
  const CurrencyPickerSearching({
    required super.filteredCurrencies,
    required super.searchQuery,
  });
}
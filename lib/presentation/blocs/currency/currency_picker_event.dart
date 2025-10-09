import 'package:equatable/equatable.dart';

abstract class CurrencyPickerEvent extends Equatable {
  const CurrencyPickerEvent();

  @override
  List<Object> get props => [];
}

class SearchQueryChanged extends CurrencyPickerEvent {
  final String query;

  const SearchQueryChanged(this.query);

   @override
  List<Object> get props => [query];
}

class CurrencyPickerInitialized extends CurrencyPickerEvent {
  const CurrencyPickerInitialized();
}

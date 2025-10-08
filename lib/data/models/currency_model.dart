import 'package:equatable/equatable.dart';
import '../../core/constants/currency_data.dart';

class CurrencyModel extends Equatable {
  final String code;
  final String name;
  final String symbol;
  final String flag;

  const CurrencyModel({
    required this.code,
    required this.name,
    required this.symbol,
    required this.flag,
  });

  factory CurrencyModel.fromCode(String code) {
    final data = CurrencyData.currencies[code];
    return CurrencyModel(
      code: code,
      name: data?['name'] ?? code,
      symbol: data?['symbol'] ?? code,
      flag: data?['flag'] ?? '🏳️',
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    'symbol': symbol,
    'flag': flag,
  };

  factory CurrencyModel.fromJson(Map<String, dynamic> json) => CurrencyModel(
    code: json['code'],
    name: json['name'],
    symbol: json['symbol'],
    flag: json['flag'],
  );

  @override
  List<Object?> get props => [code, name, symbol, flag];
}
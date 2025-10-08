import 'package:equatable/equatable.dart';

class ConversionResponse extends Equatable {
  final String base;
  final String amount;
  final ConversionResult result;
  final int ms;

  const ConversionResponse({
    required this.base,
    required this.amount,
    required this.result,
    required this.ms,
  });

  factory ConversionResponse.fromJson(Map<String, dynamic> json) {
    return ConversionResponse(
      base: json['base'],
      amount: json['amount'].toString(),
      result: ConversionResult.fromJson(json['result']),
      ms: json['ms'],
    );
  }

  Map<String, dynamic> toJson() => {
    'base': base,
    'amount': amount,
    'result': result.toJson(),
    'ms': ms,
  };

  @override
  List<Object?> get props => [base, amount, result, ms];
}

class ConversionResult extends Equatable {
  final double rate;
  final double convertedAmount;
  final String toCurrency;

  const ConversionResult({
    required this.rate,
    required this.convertedAmount,
    required this.toCurrency,
  });

  factory ConversionResult.fromJson(Map<String, dynamic> json) {
    // The API returns a map with the currency code as key
    final toCurrency = json.keys.firstWhere((key) => key != 'rate');
    return ConversionResult(
      rate: (json['rate'] as num).toDouble(),
      convertedAmount: (json[toCurrency] as num).toDouble(),
      toCurrency: toCurrency,
    );
  }

  Map<String, dynamic> toJson() => {
    toCurrency: convertedAmount,
    'rate': rate,
  };

  @override
  List<Object?> get props => [rate, convertedAmount, toCurrency];
}
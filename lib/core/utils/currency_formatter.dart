import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(double amount, {int decimals = 2}) {
    final formatter = NumberFormat.currency(
      symbol: '',
      decimalDigits: decimals,
    );
    return formatter.format(amount).trim();
  }

  static String formatWithSymbol(double amount, String currencyCode) {
    final formatter = NumberFormat.currency(
      symbol: currencyCode,
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }
}
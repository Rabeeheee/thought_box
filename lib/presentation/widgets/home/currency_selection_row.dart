import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thought_box/presentation/blocs/conversion/conversion_bloc.dart';
import 'package:thought_box/presentation/blocs/conversion/conversion_event.dart';
import 'package:thought_box/presentation/widgets/currency_picker.dart';
import '../../../../data/models/currency_model.dart';
import 'currency_chip.dart';

class CurrencySelectionRow extends StatelessWidget {
  final CurrencyModel fromCurrency;
  final CurrencyModel toCurrency;

  const CurrencySelectionRow({
    super.key,
    required this.fromCurrency,
    required this.toCurrency,
  });

  void _showCurrencyPicker({
    required BuildContext context,
    required bool isFrom,
    required String selectedCode,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CurrencyPicker(
        selectedCode: selectedCode,
        onSelected: (currency) {
          context.read<ConversionBloc>().add(
                CurrencySelected(
                  currencyCode: currency.code,
                  isFrom: isFrom,
                ),
              );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CurrencyChip(
            currency: fromCurrency,
            label: 'From',
            onTap: () => _showCurrencyPicker(
              context: context,
              isFrom: true,
              selectedCode: fromCurrency.code,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: IconButton(
            onPressed: () {
              context.read<ConversionBloc>().add(const CurrenciesSwapped());
            },
            icon: const Icon(Icons.swap_horiz),
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
        Expanded(
          child: CurrencyChip(
            currency: toCurrency,
            label: 'To',
            onTap: () => _showCurrencyPicker(
              context: context,
              isFrom: false,
              selectedCode: toCurrency.code,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2);
  }
}
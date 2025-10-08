import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:thought_box/presentation/screens/trend/trend_screen.dart';
import 'package:thought_box/presentation/widgets/result_card.dart';
import 'package:thought_box/presentation/widgets/shimmer_loading.dart';
import '../../../../data/models/conversion_response.dart';
import '../../../../data/models/currency_model.dart';

class ConversionResultSection extends StatelessWidget {
  final bool isLoading;
  final ConversionResponse? response;
  final String? errorMessage;
  final CurrencyModel fromCurrency;
  final CurrencyModel toCurrency;
  final VoidCallback onSwap;

  const ConversionResultSection({
    super.key,
    required this.isLoading,
    this.response,
    this.errorMessage,
    required this.fromCurrency,
    required this.toCurrency,
    required this.onSwap,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const ShimmerLoading(
        width: double.infinity,
        height: 200,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      );
    }

    if (response != null) {
      return Column(
        children: [
          ResultCard(
            response: response!,
            fromCurrency: fromCurrency,
            toCurrency: toCurrency,
            onSwap: onSwap,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TrendScreen(
                    fromCurrency: fromCurrency,
                    toCurrency: toCurrency,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.show_chart),
            label: const Text('View 5-Day Trend'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 24,
              ),
            ),
          ).animate().fadeIn(delay: 200.ms),
        ],
      );
    }

    if (errorMessage != null) {
      return Card(
        color: Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),
            ],
          ),
        ),
      ).animate().shake();
    }

    return const SizedBox.shrink();
  }
}
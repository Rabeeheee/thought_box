import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/conversion_response.dart';
import '../../data/models/currency_model.dart';

class ResultCard extends StatefulWidget {
  final ConversionResponse response;
  final CurrencyModel fromCurrency;
  final CurrencyModel toCurrency;
  final VoidCallback onSwap;

  const ResultCard({
    super.key,
    required this.response,
    required this.fromCurrency,
    required this.toCurrency,
    required this.onSwap,
  });

  @override
  State<ResultCard> createState() => _ResultCardState();
}

class _ResultCardState extends State<ResultCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _countController;
  late Animation<double> _countAnimation;

  @override
  void initState() {
    super.initState();
    _countController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _countAnimation = Tween<double>(
      begin: 0,
      end: widget.response.result.convertedAmount,
    ).animate(CurvedAnimation(
      parent: _countController,
      curve: Curves.easeOut,
    ));
    _countController.forward();
  }

  @override
  void didUpdateWidget(ResultCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.response != widget.response) {
      _countAnimation = Tween<double>(
        begin: 0,
        end: widget.response.result.convertedAmount,
      ).animate(CurvedAnimation(
        parent: _countController,
        curve: Curves.easeOut,
      ));
      _countController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _countController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Converted Amount',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer
                                  .withOpacity(0.7),
                            ),
                      ),
                      const SizedBox(height: 8),
                      AnimatedBuilder(
                        animation: _countAnimation,
                        builder: (context, child) {
                          return Text(
                            '${widget.toCurrency.symbol} ${CurrencyFormatter.format(_countAnimation.value)}',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                ),
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.toCurrency.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer
                                  .withOpacity(0.7),
                            ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: widget.onSwap,
                  icon: const Icon(Icons.swap_vert),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                )
                    .animate()
                    .rotate(duration: 300.ms)
                    .scale(delay: 100.ms),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Exchange Rate',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    '1 ${widget.fromCurrency.code} = ${CurrencyFormatter.format(widget.response.result.rate)} ${widget.toCurrency.code}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .slideY(begin: 0.3, duration: 400.ms, curve: Curves.easeOut)
        .fadeIn(duration: 400.ms);
  }
}
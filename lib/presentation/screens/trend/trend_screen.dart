import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/currency_model.dart';
import '../../blocs/trend/trend_bloc.dart';
import '../../blocs/trend/trend_event.dart';
import '../../blocs/trend/trend_state.dart';

class TrendScreen extends StatelessWidget {
  final CurrencyModel fromCurrency;
  final CurrencyModel toCurrency;

  const TrendScreen({
    super.key,
    required this.fromCurrency,
    required this.toCurrency,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TrendBloc()
        ..add(TrendInitialized(
          fromCurrency: fromCurrency.code,
          toCurrency: toCurrency.code,
        )),
      child: Scaffold(
        appBar: AppBar(
          title: Text('${fromCurrency.code} → ${toCurrency.code}'),
        ),
        body: const SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: _TrendContent(),
        ),
      ),
    );
  }
}

class _TrendContent extends StatelessWidget {
  const _TrendContent();

  Widget _buildStatCard({
    required BuildContext context,
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrendBloc, TrendState>(
      builder: (context, state) {
        if (state.spots.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '5-Day Trend',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ).animate().fadeIn().slideX(begin: -0.2),
            const SizedBox(height: 24),

            // Statistics Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context: context,
                    label: 'Min',
                    value: state.minRate.toStringAsFixed(4),
                    color: Colors.red,
                    icon: Icons.arrow_downward,
                  ).animate().fadeIn(delay: 100.ms).scale(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context: context,
                    label: 'Avg',
                    value: state.avgRate.toStringAsFixed(4),
                    color: Colors.blue,
                    icon: Icons.show_chart,
                  ).animate().fadeIn(delay: 200.ms).scale(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context: context,
                    label: 'Max',
                    value: state.maxRate.toStringAsFixed(4),
                    color: Colors.green,
                    icon: Icons.arrow_upward,
                  ).animate().fadeIn(delay: 300.ms).scale(),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Chart
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Exchange Rate History',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 300,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: true,
                            horizontalInterval: 0.05,
                            verticalInterval: 1,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                // ignore: deprecated_member_use
                                color: Colors.grey.withOpacity(0.2),
                                strokeWidth: 1,
                              );
                            },
                            getDrawingVerticalLine: (value) {
                              return FlLine(
                                // ignore: deprecated_member_use
                                color: Colors.grey.withOpacity(0.2),
                                strokeWidth: 1,
                              );
                            },
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                interval: 1,
                                getTitlesWidget: (double value, TitleMeta meta) {
                                  if (value.toInt() >= 0 &&
                                      value.toInt() < state.dates.length) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        state.dates[value.toInt()],
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 0.05,
                                reservedSize: 42,
                                getTitlesWidget: (double value, TitleMeta meta) {
                                  return Text(
                                    value.toStringAsFixed(2),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(
                              // ignore: deprecated_member_use
                              color: Colors.grey.withOpacity(0.2),
                            ),
                          ),
                          minX: 0,
                          maxX: 4,
                          minY: state.minRate - 0.1,
                          maxY: state.maxRate + 0.1,
                          lineBarsData: [
                            LineChartBarData(
                              spots: state.spots,
                              isCurved: true,
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(context).colorScheme.secondary,
                                ],
                              ),
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: state.selectedIndex == index ? 6 : 4,
                                    color: Theme.of(context).colorScheme.primary,
                                    strokeWidth: 2,
                                    strokeColor: Colors.white,
                                  );
                                },
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context)
                                        .colorScheme
                                        .primary
                                        // ignore: deprecated_member_use
                                        .withOpacity(0.3),
                                    Theme.of(context)
                                        .colorScheme
                                        .primary
                                        // ignore: deprecated_member_use
                                        .withOpacity(0.0),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ],
                          lineTouchData: LineTouchData(
                            enabled: true,
                            touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
                              if (response != null &&
                                  response.lineBarSpots != null) {
                                context.read<TrendBloc>().add(
                                      TrendPointSelected(
                                        response.lineBarSpots!.first.spotIndex,
                                      ),
                                    );
                              }
                            },
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                                return touchedBarSpots.map((barSpot) {
                                  return LineTooltipItem(
                                    '${state.dates[barSpot.x.toInt()]}\n${barSpot.y.toStringAsFixed(4)}',
                                    const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                }).toList();
                              },
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Info Card
            Card(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'This is mock data for demonstration purposes. Real historical data would be fetched from the API.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 500.ms),
          ],
        );
      },
    );
  }
}
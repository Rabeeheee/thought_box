import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thought_box/presentation/blocs/conversion/conversion_bloc.dart';
import 'package:thought_box/presentation/blocs/conversion/conversion_event.dart';
import '../../../core/constants/currency_data.dart';


class RecentPairsList extends StatelessWidget {
  final List<String> recentPairs;

  const RecentPairsList({
    super.key,
    required this.recentPairs,
  });

  @override
  Widget build(BuildContext context) {
    if (recentPairs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.history,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Recent Conversions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(width: 8),
            
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: recentPairs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final pair = recentPairs[index].split('-');
              return ActionChip(
                avatar: Text(CurrencyData.currencies[pair[0]]?['flag'] ?? ''),
                label: Text('${pair[0]} → ${pair[1]}'),
                onPressed: () {
                  context.read<ConversionBloc>().add(
                        RecentPairSelected(
                          from: pair[0],
                          to: pair[1],
                        ),
                      );
                },
              ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.2);
            },
          ),
        ),
        const SizedBox(height: 8),
        
      ],
    );
  }
}
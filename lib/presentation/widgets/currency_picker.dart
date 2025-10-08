import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thought_box/presentation/blocs/currency/currency_picker_bloc.dart';
import 'package:thought_box/presentation/blocs/currency/currency_picker_event.dart';
import 'package:thought_box/presentation/blocs/currency/currency_picker_state.dart';
import '../../data/models/currency_model.dart';


class CurrencyPicker extends StatelessWidget {
  final Function(CurrencyModel) onSelected;
  final String? selectedCode;

  const CurrencyPicker({
    super.key,
    required this.onSelected,
    this.selectedCode,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CurrencyPickerBloc()..add(const CurrencyPickerInitialized()),
      child: _CurrencyPickerContent(
        onSelected: onSelected,
        selectedCode: selectedCode,
      ),
    );
  }
}

class _CurrencyPickerContent extends StatefulWidget {
  final Function(CurrencyModel) onSelected;
  final String? selectedCode;

  const _CurrencyPickerContent({
    required this.onSelected,
    this.selectedCode,
  });

  @override
  State<_CurrencyPickerContent> createState() => _CurrencyPickerContentState();
}

class _CurrencyPickerContentState extends State<_CurrencyPickerContent> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      context.read<CurrencyPickerBloc>().add(
            SearchQueryChanged(_searchController.text),
          );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Currency',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search currency...',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<CurrencyPickerBloc, CurrencyPickerState>(
              builder: (context, state) {
                final currencies = state.filteredCurrencies;

                if (currencies.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No currencies found',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try a different search term',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: currencies.length,
                  itemBuilder: (context, index) {
                    final currency = currencies[index];
                    final isSelected = currency.code == widget.selectedCode;

                    return ListTile(
                      leading: Hero(
                        tag: 'currency_${currency.code}',
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          child: Text(
                            currency.flag,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      title: Text(
                        currency.code,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(currency.name),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                      selected: isSelected,
                      onTap: () {
                        widget.onSelected(currency);
                        Navigator.pop(context);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../core/constants/currency_data.dart';
import '../../data/models/currency_model.dart';

class CurrencyPicker extends StatefulWidget {
  final Function(CurrencyModel) onSelected;
  final String? selectedCode;

  const CurrencyPicker({
    super.key,
    required this.onSelected,
    this.selectedCode,
  });

  @override
  State<CurrencyPicker> createState() => _CurrencyPickerState();
}

class _CurrencyPickerState extends State<CurrencyPicker> {
  final TextEditingController _searchController = TextEditingController();
  List<CurrencyModel> _currencies = [];
  List<CurrencyModel> _filteredCurrencies = [];

  @override
  void initState() {
    super.initState();
    _currencies = CurrencyData.currencyCodes
        .map((code) => CurrencyModel.fromCode(code))
        .toList();
    _filteredCurrencies = _currencies;
    _searchController.addListener(_filterCurrencies);
  }

  void _filterCurrencies() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCurrencies = _currencies.where((currency) {
        return currency.code.toLowerCase().contains(query) ||
            currency.name.toLowerCase().contains(query);
      }).toList();
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
            child: ListView.builder(
              itemCount: _filteredCurrencies.length,
              itemBuilder: (context, index) {
                final currency = _filteredCurrencies[index];
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
            ),
          ),
        ],
      ),
    );
  }
}
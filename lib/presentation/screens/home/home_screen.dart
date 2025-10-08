import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/currency_data.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/currency_model.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/conversion/conversion_bloc.dart';
import '../../blocs/conversion/conversion_event.dart';
import '../../blocs/conversion/conversion_state.dart';
import '../../widgets/animated_button.dart';
import '../../widgets/currency_picker.dart';
import '../../widgets/result_card.dart';
import '../../widgets/shake_widget.dart';
import '../../widgets/shimmer_loading.dart';
import '../auth/login_screen.dart';
import '../trend/trend_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _amountController = TextEditingController(text: '100');
  final _formKey = GlobalKey<FormState>();
  
  CurrencyModel _fromCurrency = CurrencyModel.fromCode('USD');
  CurrencyModel _toCurrency = CurrencyModel.fromCode('EUR');
  bool _showError = false;

  @override
  void initState() {
    super.initState();
    context.read<ConversionBloc>().add(LoadRecentPairs());
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _showCurrencyPicker({required bool isFrom}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CurrencyPicker(
        selectedCode: isFrom ? _fromCurrency.code : _toCurrency.code,
        onSelected: (currency) {
          setState(() {
            if (isFrom) {
              _fromCurrency = currency;
            } else {
              _toCurrency = currency;
            }
          });
        },
      ),
    );
  }

  void _handleConvert() {
    setState(() => _showError = false);
    
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      context.read<ConversionBloc>().add(
            ConvertCurrencyRequested(
              from: _fromCurrency.code,
              to: _toCurrency.code,
              amount: amount,
            ),
          );
    } else {
      setState(() => _showError = true);
    }
  }

  void _handleSwap() {
    if (_amountController.text.isNotEmpty) {
      final amount = double.parse(_amountController.text);
      context.read<ConversionBloc>().add(
            SwapCurrenciesRequested(
              from: _fromCurrency.code,
              to: _toCurrency.code,
              amount: amount,
            ),
          );
      setState(() {
        final temp = _fromCurrency;
        _fromCurrency = _toCurrency;
        _toCurrency = temp;
      });
    }
  }

  Widget _buildCurrencyChip({
    required CurrencyModel currency,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Hero(
              tag: 'currency_${currency.code}',
              child: Text(
                currency.flag,
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                Text(
                  currency.code,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Converter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(AuthSignOutRequested());
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recent Pairs
                BlocBuilder<ConversionBloc, ConversionState>(
                  builder: (context, state) {
                    List<String> recentPairs = [];
                    
                    if (state is ConversionSuccess) {
                      recentPairs = state.recentPairs;
                    } else if (state is ConversionWithRecent) {
                      recentPairs = state.recentPairs;
                    }

                    if (recentPairs.isEmpty) return const SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recent',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
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
                                  setState(() {
                                    _fromCurrency = CurrencyModel.fromCode(pair[0]);
                                    _toCurrency = CurrencyModel.fromCode(pair[1]);
                                  });
                                },
                              ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.2);
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    );
                  },
                ),

                // Currency Selection
                Row(
                  children: [
                    Expanded(
                      child: _buildCurrencyChip(
                        currency: _fromCurrency,
                        label: 'From',
                        onTap: () => _showCurrencyPicker(isFrom: true),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            final temp = _fromCurrency;
                            _fromCurrency = _toCurrency;
                            _toCurrency = temp;
                          });
                        },
                        icon: const Icon(Icons.swap_horiz),
                        style: IconButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _buildCurrencyChip(
                        currency: _toCurrency,
                        label: 'To',
                        onTap: () => _showCurrencyPicker(isFrom: false),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                
                const SizedBox(height: 24),

                // Amount Input
                ShakeWidget(
                  shake: _showError,
                  child: TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      prefixIcon: const Icon(Icons.attach_money),
                      suffixText: _fromCurrency.code,
                    ),
                    validator: Validators.amount,
                  ),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
                
                const SizedBox(height: 24),

                // Convert Button
                BlocBuilder<ConversionBloc, ConversionState>(
                  builder: (context, state) {
                    return AnimatedButton(
                      onPressed: _handleConvert,
                      text: 'Convert',
                      isLoading: state is ConversionLoading,
                    );
                  },
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),

                const SizedBox(height: 24),

                // Result
                BlocBuilder<ConversionBloc, ConversionState>(
                  builder: (context, state) {
                    if (state is ConversionLoading) {
                      return const ShimmerLoading(
                        width: double.infinity,
                        height: 200,
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      );
                    }
                    
                    if (state is ConversionSuccess) {
                      return Column(
                        children: [
                          ResultCard(
                            response: state.response,
                            fromCurrency: _fromCurrency,
                            toCurrency: _toCurrency,
                            onSwap: _handleSwap,
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => TrendScreen(
                                    fromCurrency: _fromCurrency,
                                    toCurrency: _toCurrency,
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
                    
                    if (state is ConversionError) {
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
                                  state.message,
                                  style: TextStyle(color: Colors.red.shade700),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().shake();
                    }
                    
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thought_box/presentation/widgets/amount_input_field.dart';
import 'package:thought_box/presentation/widgets/conversion_result_section.dart';
import 'package:thought_box/presentation/widgets/currency_selection_row.dart';
import 'package:thought_box/presentation/widgets/recent_pairs_list.dart';
import '../../../data/models/currency_model.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/conversion/conversion_bloc.dart';
import '../../blocs/conversion/conversion_event.dart';
import '../../blocs/conversion/conversion_state.dart';
import '../../widgets/animated_button.dart';
import '../auth/login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Load recent pairs on first build
    context.read<ConversionBloc>().add(LoadRecentPairs());

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
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: _HomeContent(),
        ),
      ),
    );
  }
}

class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  final _amountController = TextEditingController(text: '100');
  final _formKey = GlobalKey<FormState>();
  bool _showError = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _handleConvert(String from, String to) {
    if (_formKey.currentState!.validate()) {
      setState(() => _showError = false);
      final amount = double.parse(_amountController.text);
      context.read<ConversionBloc>().add(
            ConvertCurrencyRequested(
              from: from,
              to: to,
              amount: amount,
            ),
          );
    } else {
      setState(() => _showError = true);
    }
  }

  void _handleSwap(String from, String to) {
    if (_amountController.text.isNotEmpty &&
        _formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      context.read<ConversionBloc>().add(
            SwapCurrenciesRequested(
              from: from,
              to: to,
              amount: amount,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConversionBloc, ConversionState>(
      builder: (context, state) {
        final fromCurrency = CurrencyModel.fromCode(state.fromCurrency);
        final toCurrency = CurrencyModel.fromCode(state.toCurrency);

        List<String> recentPairs = [];
        if (state is ConversionSuccess) {
          recentPairs = state.recentPairs;
        } else if (state is ConversionWithRecent) {
          recentPairs = state.recentPairs;
        }

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recent Pairs
             RecentPairsList(
  recentPairs: recentPairs,
),

              // Currency Selection
              CurrencySelectionRow(
                fromCurrency: fromCurrency,
                toCurrency: toCurrency,
              ),

              const SizedBox(height: 24),

              // Amount Input
              AmountInputField(
                controller: _amountController,
                currencyCode: fromCurrency.code,
                showError: _showError,
              ),

              const SizedBox(height: 24),

              // Convert Button
              AnimatedButton(
                onPressed: () => _handleConvert(
                  state.fromCurrency,
                  state.toCurrency,
                ),
                text: 'Convert',
                isLoading: state is ConversionLoading,
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),

              const SizedBox(height: 24),

              // Result
              ConversionResultSection(
                isLoading: state is ConversionLoading,
                response: state is ConversionSuccess ? state.response : null,
                errorMessage:
                    state is ConversionError ? state.message : null,
                fromCurrency: fromCurrency,
                toCurrency: toCurrency,
                onSwap: () => _handleSwap(
                  state.fromCurrency,
                  state.toCurrency,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
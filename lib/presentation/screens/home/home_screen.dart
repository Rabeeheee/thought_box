import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/currency_model.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart' hide ValidationErrorTriggered, ValidationErrorCleared;
import '../../blocs/conversion/conversion_bloc.dart';
import '../../blocs/conversion/conversion_event.dart';
import '../../blocs/conversion/conversion_state.dart';
import '../../widgets/animated_button.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/home/amount_input_field.dart';
import '../../widgets/home/conversion_result_section.dart';
import '../../widgets/home/currency_selection_row.dart';
import '../../widgets/home/recent_pairs_list.dart';
import '../auth/login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Logout',
      message: 'Are you sure you want to logout?\n\nAll cached data will be cleared.',
      confirmText: 'Logout',
      cancelText: 'Cancel',
      icon: Icons.logout,
      iconColor: Colors.red,
    );

    if (confirmed == true && context.mounted) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Logging out...'),
                  SizedBox(height: 4),
                  Text(
                    'Clearing cache data',
                     style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      context.read<AuthBloc>().add(AuthSignOutRequested());

      await Future.delayed(const Duration(milliseconds: 500));

      if (context.mounted) {
        Navigator.of(context).pop();

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Logged out successfully'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    context.read<ConversionBloc>().add(LoadRecentPairs());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Converter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _handleLogout(context),
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

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _handleConvert(BuildContext context, String from, String to) {
    context.read<ConversionBloc>().add(const ValidationErrorCleared());

    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      context.read<ConversionBloc>().add(
            ConvertCurrencyRequested(
              from: from,
              to: to,
              amount: amount,
            ),
          );
    } else {
      context.read<ConversionBloc>().add(const ValidationErrorTriggered());
    }
  }

  void _handleSwap(BuildContext context, String from, String to) {
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
              RecentPairsList(recentPairs: recentPairs),
              CurrencySelectionRow(
                fromCurrency: fromCurrency,
                toCurrency: toCurrency,
              ),
              const SizedBox(height: 24),
              AmountInputField(
                controller: _amountController,
                currencyCode: fromCurrency.code,
                showError: state.showValidationError,
              ),
              const SizedBox(height: 24),
              AnimatedButton(
                onPressed: () => _handleConvert(
                  context,
                  state.fromCurrency,
                  state.toCurrency,
                ),
                text: 'Convert',
                isLoading: state is ConversionLoading,
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
              const SizedBox(height: 24),
              ConversionResultSection(
                isLoading: state is ConversionLoading,
                response: state is ConversionSuccess ? state.response : null,
                errorMessage: state is ConversionError ? state.message : null,
                fromCurrency: fromCurrency,
                toCurrency: toCurrency,
                onSwap: () => _handleSwap(
                  context,
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
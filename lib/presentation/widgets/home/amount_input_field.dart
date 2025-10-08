import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/utils/validators.dart';
import '../shake_widget.dart';

class AmountInputField extends StatelessWidget {
  final TextEditingController controller;
  final String currencyCode;
  final bool showError;

  const AmountInputField({
    super.key,
    required this.controller,
    required this.currencyCode,
    required this.showError,
  });

  @override
  Widget build(BuildContext context) {
    return ShakeWidget(
      shake: showError,
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: 'Amount',
          prefixIcon: const Icon(Icons.attach_money),
          suffixText: currencyCode,
        ),
        validator: Validators.amount,
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2);
  }
}
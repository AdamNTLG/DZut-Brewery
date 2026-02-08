import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_constants.dart';

/// Champ de texte personnalisé avec label
class AppTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? initialValue;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final int maxLines;
  final bool enabled;
  final Widget? suffix;
  final Widget? prefix;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.initialValue,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.maxLines = 1,
    this.enabled = true,
    this.suffix,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: AppConstants.paddingXS),
        TextFormField(
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          onChanged: onChanged,
          onSaved: onSaved,
          maxLines: maxLines,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffix,
            prefixIcon: prefix,
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey[100],
          ),
        ),
      ],
    );
  }
}

/// Champ numérique avec unité
class AppNumberField extends StatelessWidget {
  final String label;
  final String? hint;
  final String? unit;
  final TextEditingController? controller;
  final double? initialValue;
  final int decimals;
  final double? min;
  final double? max;
  final String? Function(String?)? validator;
  final void Function(double?)? onChanged;
  final bool enabled;

  const AppNumberField({
    super.key,
    required this.label,
    this.hint,
    this.unit,
    this.controller,
    this.initialValue,
    this.decimals = 1,
    this.min,
    this.max,
    this.validator,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: AppConstants.paddingXS),
        TextFormField(
          controller: controller,
          initialValue: controller == null && initialValue != null
              ? initialValue!.toStringAsFixed(decimals)
              : null,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
          ],
          validator: validator ?? (value) {
            if (value == null || value.isEmpty) return null;
            final number = double.tryParse(value.replaceAll(',', '.'));
            if (number == null) return 'Nombre invalide';
            if (min != null && number < min!) return 'Min: $min';
            if (max != null && number > max!) return 'Max: $max';
            return null;
          },
          onChanged: (value) {
            if (onChanged != null) {
              final number = double.tryParse(value.replaceAll(',', '.'));
              onChanged!(number);
            }
          },
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hint,
            suffixText: unit,
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey[100],
          ),
        ),
      ],
    );
  }
}

/// Dropdown personnalisé
class AppDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? hint;
  final bool enabled;

  const AppDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    this.onChanged,
    this.hint,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: AppConstants.paddingXS),
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items,
          onChanged: enabled ? onChanged : null,
          hint: hint != null ? Text(hint!) : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey[100],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../utils/theme.dart';

class CustomRadio<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final Function(T?) onChanged;
  final String label;

  const CustomRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<T>(
      title: Text(label),
      value: value,
      groupValue: groupValue,
      activeColor: AppColors.primary,
      onChanged: onChanged,
    );
  }
}

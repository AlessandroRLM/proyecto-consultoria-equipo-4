import 'package:flutter/material.dart';
import '../utils/theme.dart';

class CustomCheckbox extends StatelessWidget {
  final bool value;
  final Function(bool?) onChanged;
  final String label;

  const CustomCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(
        label,
        style: TextStyle(
          color: AppThemes.black_1000,
          fontWeight: FontWeight.w500,
        ),
      ),
      value: value,
      activeColor: AppThemes.primary_600,
      checkColor: AppThemes.black_100,
      tileColor: AppThemes.black_100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

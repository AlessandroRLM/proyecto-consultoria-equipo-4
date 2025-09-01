import 'package:flutter/material.dart';
import '../utils/theme.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const CustomSearchBar({
    super.key,
    required this.controller,
    this.hint = "Buscar...",
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../utils/theme.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final VoidCallback? onSearch;

  const CustomSearchBar({
    super.key,
    required this.controller,
    this.hint = "Buscar...",
    this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onSubmitted: (_) {
        if (onSearch != null) onSearch!();
      },
      decoration: InputDecoration(
        prefixIcon: IconButton(
          icon: Icon(Icons.search, color: AppThemes.black_700),
          onPressed: onSearch,
          tooltip: "Buscar",
        ),
        hintText: hint,
        filled: true,
        fillColor: AppThemes.black_100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: AppThemes.black_700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: AppThemes.primary_600, width: 2),
        ),
      ),
      style: TextStyle(color: AppThemes.black_1300),
      cursorColor: AppThemes.primary_600,
    );
  }
}

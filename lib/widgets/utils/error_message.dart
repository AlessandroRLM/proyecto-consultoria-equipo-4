import 'package:flutter/material.dart';
import 'theme.dart';

class ErrorMessage extends StatelessWidget {
  final String message;

  const ErrorMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: TextStyle(
          color: AppThemes.light.colorScheme.error,
          fontSize: 16,
        ),
      ),
    );
  }
}

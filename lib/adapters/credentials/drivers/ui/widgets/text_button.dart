import 'package:flutter/material.dart';
//import 'package:go_router/go_router.dart';

class PhotoButton extends StatelessWidget {
  final VoidCallback? funcion;
  final String label;
  final Color? color;
  final Color? textColor;

  const PhotoButton({
    super.key,
    this.funcion,
    required this.label,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        fixedSize: Size(screenWidth * 0.4, 60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        backgroundColor: color ?? Theme.of(context).colorScheme.surface,
        foregroundColor: textColor ?? Theme.of(context).colorScheme.onSurface,
      ),
      onPressed: funcion,
      child: Text(label),
    );
  }
}

import 'package:flutter/material.dart';

class HomeButton extends StatelessWidget {
  final VoidCallback funcion;
  final String label;
  final IconData? icon;
  final Color? color;
  final Color? textColor;

  const HomeButton({
    super.key,
    required this.funcion,
    required this.label,
    this.icon,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: funcion,
      style: ElevatedButton.styleFrom(
        fixedSize: const Size(300, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        backgroundColor: color ?? Theme.of(context).colorScheme.surface,
        //foregroundColor: textColor ?? Theme.of(context).colorScheme.onSurface,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: TextStyle(
              color: textColor ?? Theme.of(context).colorScheme.onSurface,
              fontSize: 16,
              //fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

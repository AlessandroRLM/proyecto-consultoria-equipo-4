import 'package:flutter/material.dart';

class IconCredentialButton extends StatelessWidget {
  final VoidCallback funcion; 
  final String label;
  final IconData icon;
  final Color? color;
  final Color? textColor; 

  const IconCredentialButton({
    super.key,
    required this.funcion,
    required this.label,
    required this.icon,
    this.color,
    this.textColor
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        fixedSize: const Size(300, 50),
        side: BorderSide(color: textColor ?? Theme.of(context).colorScheme.onSurface, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        backgroundColor: color ?? Theme.of(context).colorScheme.surface,
        foregroundColor: textColor ?? Theme.of(context).colorScheme.onSurface),
      onPressed: funcion,
      icon: Icon(icon),
      label: Text(label));
  }
}

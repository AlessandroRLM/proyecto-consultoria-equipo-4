import 'package:flutter/material.dart';
class RequestButton extends StatelessWidget {
  final VoidCallback funcion; 
  final String label;
  final Color? color;
  final IconData? icon;
  final Color? textColor;
  final String? heroTag;

  const RequestButton({
    super.key,
    required this.funcion,
    required this.label,
    this.color,
    this.icon,
    this.textColor,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
       funcion;
      },
      backgroundColor: color ?? Theme.of(context).colorScheme.primary,
      label: Text(
        label,
        style: TextStyle(
          color: textColor ?? Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      icon: icon != null
          ? Icon(icon, color: textColor ?? Theme.of(context).colorScheme.onPrimary)
          : null,
      heroTag: heroTag ?? 'request_button',
    );
  }
}

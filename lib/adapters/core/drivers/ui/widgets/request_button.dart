import 'package:flutter/material.dart';
class RequestButton extends StatelessWidget {
  final VoidCallback function; 
  final String label;
  final Color? color;
  final IconData? icon;
  final Color? textColor;
  final String? heroTag;

  const RequestButton({
    super.key,
    required this.function,
    required this.label,
    this.color,
    this.icon,
    this.textColor,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return FloatingActionButton.extended(
      onPressed: function,
      backgroundColor: color ?? Theme.of(context).colorScheme.primary,
      label: Text(
        label,
        style: textTheme.titleMedium!.copyWith(color: cs.onPrimary)
      ),
      icon: icon != null
          ? Icon(icon, color: textColor ?? Theme.of(context).colorScheme.onPrimary)
          : null,
      heroTag: heroTag ?? 'request_button',
    );
  }
}

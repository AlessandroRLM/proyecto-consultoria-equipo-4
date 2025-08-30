import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RequestCredentialButton extends StatelessWidget {
  final String route;
  final String label;
  final Color? color;
  final IconData? icon;
  final Color? textColor; 

  const RequestCredentialButton({
    super.key,
    required this.route,
    required this.label,
    this.color,
    this.icon,
    this.textColor
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        context.go(route);
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
    );
  }
}

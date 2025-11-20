import 'package:flutter/material.dart';
import 'package:mobile/adapters/core/driven/app_themes.dart';

class ServiceItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool bordered; // para reusar estilo viejo si hiciera falta

  const ServiceItem({
    super.key,
    required this.icon,
    required this.label,
    this.bordered = false,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    if (bordered) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppThemes.primary_600),
            const SizedBox(width: 6),
            Text(label, style: text.bodySmall),
          ],
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppThemes.primary_600),
        const SizedBox(width: 8),
        Text(label, style: text.bodySmall),
      ],
    );
  }
}

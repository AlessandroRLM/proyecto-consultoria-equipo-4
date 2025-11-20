import 'package:flutter/material.dart';
import 'package:mobile/adapters/core/driven/app_themes.dart';
class ReservationButtonWidget extends StatelessWidget {
  final bool isOutbound;
  final String? selectedLocation;
  final Map<String, dynamic>? selectedOption;
  final VoidCallback onReservar;

  const ReservationButtonWidget({
    super.key,
    required this.isOutbound,
    required this.selectedLocation,
    required this.selectedOption,
    required this.onReservar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            spreadRadius: 0,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transporte de ${isOutbound ? 'Ida' : 'Vuelta'}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                if (selectedLocation?.isNotEmpty ?? false)
                  Text(
                    '$selectedLocation',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: onSurface.withValues(alpha: 0.7),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
              ],
            ),
          ),
          SizedBox(
            height: 40,
            child: ElevatedButton(
              onPressed: selectedOption != null ? onReservar : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedOption != null ? AppThemes.primary_600 : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Reservar',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

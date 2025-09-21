import 'package:flutter/material.dart';
import 'package:mobile/adapters/core/driven/app_themes.dart';

class MapControlButtons extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onMyLocation;

  const MapControlButtons({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onMyLocation,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Botones de zoom
            Container(
              width: 44,
              decoration: _containerDecoration(cs),
              child: Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add, color: AppThemes.primary_600),
                    onPressed: onZoomIn,
                  ),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppThemes.primary_600,
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove, color: AppThemes.primary_600),
                    onPressed: onZoomOut,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            // Botón de ubicación actual
            Container(
              width: 44,
              decoration: _containerDecoration(cs),
              child: IconButton(
                icon: const Icon(Icons.my_location, color: AppThemes.primary_600),
                onPressed: onMyLocation,
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _containerDecoration(ColorScheme cs) {

    return BoxDecoration(
      color: cs.surface,
      borderRadius: BorderRadius.circular(8.0),
      border: Border.all(color: AppThemes.primary_600, width: 1.0),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 4.0,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}
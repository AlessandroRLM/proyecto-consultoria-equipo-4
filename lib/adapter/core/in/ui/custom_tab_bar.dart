import 'package:flutter/material.dart';
import 'package:mobile/adapter/core/out/app_themes.dart';

class CustomTabBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomTabBar({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      spacing: 8.0,
      children: [
        _buildTabItem(context, 0, Icons.credit_card_outlined, 'Credencial'),
        _buildTabItem(context, 1, Icons.airport_shuttle_outlined, 'Transporte'),
        _buildTabItem(context, 2, Icons.hotel_outlined, 'Alojamiento'),
      ],
    );
  }

  Widget _buildTabItem(
    BuildContext context,
    int index,
    IconData icon,
    String label,
  ) {
    final cs = Theme.of(context).colorScheme;
    final isSelected = currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          height: 36,
          decoration: BoxDecoration(
            color: isSelected ? cs.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? cs.onPrimaryContainer : cs.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

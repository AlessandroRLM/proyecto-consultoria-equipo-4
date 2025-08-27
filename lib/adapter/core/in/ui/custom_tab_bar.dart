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
    return Row(
      spacing: 8.0,
      children: [
        _buildTabItem(0, Icons.credit_card_outlined, 'Credencial'),
        _buildTabItem(1, Icons.airport_shuttle_outlined, 'Transporte'),
        _buildTabItem(2, Icons.hotel_outlined, 'Alojamiento'),
      ],
    );
  }

  Widget _buildTabItem(int index, IconData icon, String label) {
    final isSelected = currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          height: 36,
          decoration: BoxDecoration(
            color: isSelected ? AppThemes.primary_200 : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppThemes.black_500
            )
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? (AppThemes.primary_700) : AppThemes.black_1300,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold ,
                  color: isSelected
                      ? AppThemes.primary_700
                      : AppThemes.black_1300,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

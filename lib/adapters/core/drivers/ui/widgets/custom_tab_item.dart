import 'package:flutter/material.dart';
import 'package:mobile/adapters/core/drivens/app_themes.dart';

class CustomTabItem extends StatelessWidget {
  final int currentIndex;
  final Function(int p1) onTap;
  final int index;
  final IconData icon;
  final String label;

  const CustomTabItem({
    required this.currentIndex,
    required this.onTap,
    required this.index,
    required this.icon,
    required this.label,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          height: 36,
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).brightness == Brightness.light
                      ? AppThemes.primary_200
                      : AppThemes.primary_700
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppThemes.black_500),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? Theme.of(context).brightness == Brightness.light
                          ? AppThemes.primary_700
                          : AppThemes.primary_200
                    : Theme.of(context).brightness == Brightness.light
                          ? AppThemes.black_1300
                          : AppThemes.black_100,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? Theme.of(context).brightness == Brightness.light
                            ? AppThemes.primary_700
                            : AppThemes.primary_200
                      : Theme.of(context).brightness == Brightness.light
                            ? AppThemes.black_1300
                            : AppThemes.black_100,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../utils/theme.dart';

class ItemCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const ItemCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(title, style: TextStyle(color: AppColors.textPrimary)),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: AppColors.textSecondary),
        ),
        onTap: onTap,
      ),
    );
  }
}

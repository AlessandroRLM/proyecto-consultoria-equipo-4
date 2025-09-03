import 'package:flutter/material.dart';
import '../utils/theme.dart'; // Ajusta según donde tengas tus colores

class ItemCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final IconData? icon;

  const ItemCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppThemes.black_100, // fondo claro de la tarjeta
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: icon != null
            ? Icon(
                icon,
                size: 28,
                color: AppThemes.primary_600, // color visible y acorde a tema
              )
            : null,
        title: Text(
          title,
          style: TextStyle(
            color: AppThemes.black_1000,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: AppThemes.black_700, fontSize: 14),
        ),
        onTap: onTap,
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppThemes.black_800,
        ),
      ),
    );
  }
}

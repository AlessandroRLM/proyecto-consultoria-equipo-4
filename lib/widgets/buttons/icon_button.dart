import 'package:flutter/material.dart';
import 'package:mobile/widgets/utils/theme.dart'; // Ajusta ruta

class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
  final double size;

  const CustomIconButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.size = 28.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(
            8.0,
          ), // Ajusta el padding para zona táctil
          child: Icon(icon, color: color ?? AppThemes.primary_600, size: size),
        ),
      ),
    );
  }
}

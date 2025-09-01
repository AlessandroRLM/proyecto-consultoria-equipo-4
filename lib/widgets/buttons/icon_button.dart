import 'package:flutter/material.dart';
import 'package:mobile/widgets/buttons/icon_button.dart'; // <-- ojo, ajusta si tu ruta es distinta
import 'package:mobile/widgets/utils/theme.dart'; // si AppColors está en otro archivo, importa ahí

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
    return IconButton(
      icon: Icon(icon, color: color ?? AppColors.primary, size: size),
      onPressed: onPressed,
      splashRadius: size, // mejora UX en pantallas táctiles
    );
  }
}

import 'package:flutter/material.dart';

class StatusWidget extends StatelessWidget {
  final String estado;

  StatusWidget({super.key, required this.estado});

  // Mapa de colores por estado
  final Map<String, Color> colores = {
    "Pendiente": Colors.yellow,
    "Cursada": Colors.blue,
    "Activa": Colors.green,
    "Aceptada": Colors.purple,
    "Iniciada": Colors.pink,
    "Finalizada": Colors.grey,
  };
  

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = colores[estado[0].toUpperCase() + estado.substring(1).toLowerCase()] ?? Colors.grey;


    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2), // Fondo con transparencia
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        estado,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: color, // Texto sólido con el color plano
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }
}

import 'package:flutter/material.dart';

class LodgingMapScreen extends StatelessWidget {
  const LodgingMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Mapa de alojamientos")),
      body: Center(
        child: Text("Aqui ira el mapa", style: TextStyle(color: cs.onSurface)),
      ),
    );
  }
}

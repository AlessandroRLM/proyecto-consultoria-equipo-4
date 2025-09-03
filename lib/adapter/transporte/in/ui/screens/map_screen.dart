import 'package:flutter/material.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa'), backgroundColor: Colors.white),
      body: const Center(
        // Placeholder mapa
        child: Text('Aquí se mostrará el mapa.'),
      ),
    );
  }
}

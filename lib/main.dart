import 'package:flutter/material.dart';

// Importa tus widgets personalizados
import 'widgets/buttons/custom_button.dart';
import 'widgets/buttons/icon_button.dart';
import 'widgets/inputs/custom_textfield.dart';
import 'widgets/inputs/search_bar.dart';
import 'widgets/cards/item_card.dart';
import 'widgets/cards/profile_card.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Demo Widgets',
      theme: ThemeData(primarySwatch: Colors.red),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Prueba Widgets")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "🔹 Botones",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          CustomButton(
            text: "Botón XS",
            size: ButtonSize.xs,
            onPressed: () {
              print("XS presionado");
            },
          ),
          const SizedBox(height: 10),

          CustomButton(
            text: "Botón Small",
            size: ButtonSize.sm,
            onPressed: () {
              print("Small presionado");
            },
          ),
          const SizedBox(height: 10),

          CustomButton(
            text: "Botón Mediano",
            size: ButtonSize.md,
            onPressed: () {
              print("Mediano presionado");
            },
          ),
          const SizedBox(height: 10),

          CustomButton(
            text: "Botón Grande",
            size: ButtonSize.lg,
            onPressed: () {
              print("Grande presionado");
            },
          ),
          const SizedBox(height: 10),

          CustomButton(
            text: "Botón Deshabilitado",
            size: ButtonSize.md,
            status: ButtonStatus.disabled,
            onPressed: () {}, // No se ejecutará
          ),
          const SizedBox(height: 10),

          // Botón con ícono a la derecha
          CustomButton(
            text: "Botón con ícono derecha",
            size: ButtonSize.md,
            icon: Icons.thumb_up,
            iconRight: true,
            onPressed: () {
              print("Botón con ícono derecha presionado");
            },
          ),
          const SizedBox(height: 10),

          // Botón que simula estar presionado (estado pressed)
          CustomButton(
            text: "Botón Presionado",
            size: ButtonSize.md,
            status: ButtonStatus.pressed,
            onPressed: () {
              print("Botón Presionado clickeado");
            },
          ),

          const SizedBox(height: 20),

          CustomIconButton(
            icon: Icons.emoji_transportation,
            onPressed: () {
              print("Icon Button");
            },
          ),

          const Divider(),

          const Text(
            "🔹 Inputs",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          CustomTextField(hint: "Hola", controller: TextEditingController()),
          const SizedBox(height: 10),
          CustomSearchBar(
            controller: TextEditingController(),
            onSearch: () {
              // Aquí la lógica que quieres al presionar la lupa o enter
              print("Buscar accionada");
            },
          ),
          const Divider(),

          const Text(
            "🔹 Tarjetas",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ItemCard(
            title: "Transporte",
            subtitle: "Reserva disponible",
            icon: Icons.directions_bus,
            onTap: () {
              print("Transporte tocado");
            },
          ),

          const SizedBox(height: 10),
          const ProfileCard(
            name: "Juan Pérez",
            email: "juan.perez@ejemplo.com",
            imageUrl: "https://via.placeholder.com/150",
          ),
        ],
      ),
    );
  }
}

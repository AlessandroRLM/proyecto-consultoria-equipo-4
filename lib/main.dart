import 'package:flutter/material.dart';

// importa tus widgets personalizados
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
      theme: ThemeData(primarySwatch: Colors.blue),
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
          // 🔹 Botones
          CustomButton(text: "Botón Principal", onPressed: () {}),
          const SizedBox(height: 10),
          CustomIconButton(icon: Icons.home, onPressed: () {}),

          const Divider(),

          // 🔹 Inputs
          CustomTextField(hint: "Hola", controller: TextEditingController()),
          const SizedBox(height: 10),
          const SearchBar(),

          const Divider(),

          // 🔹 Tarjetas
          ItemCard(
            title: "Transporte",
            subtitle: "Reserva disponible",
            onTap: () {
              print("object");
            },
          ),
          SizedBox(height: 10),
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

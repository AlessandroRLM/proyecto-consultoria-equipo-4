import 'package:flutter/material.dart';

// Widgets
import 'widgets/buttons/custom_button.dart';
import 'widgets/buttons/icon_button.dart';
import 'widgets/inputs/custom_textfield.dart';
import 'widgets/inputs/search_bar.dart';
import 'widgets/forms/custom_date_picker.dart';
import 'widgets/forms/custom_dropdown.dart';
import 'widgets/forms/custom_checkbox.dart';
import 'widgets/forms/custom_radio.dart';
import 'widgets/cards/item_card.dart';
import 'widgets/cards/profile_card.dart';
import 'widgets/utils/loading_indicator.dart';
import 'widgets/utils/error_message.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Widgets Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Widgets Globales")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🔹 Botones
          const Text(
            "Botones",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          CustomButton(text: "Botón Principal", onPressed: () {}),
          const SizedBox(height: 10),
          IconButton(icon: Icons.home, onPressed: () {}),

          const Divider(),

          // 🔹 Inputs
          const Text(
            "Inputs",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const TextField(label: "Escribe algo"),
          const SizedBox(height: 10),
          const SearchBar(),

          const Divider(),

          // 🔹 Formularios
          const Text(
            "Formularios",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          CustomDatePicker(onDateSelected: (date) {}),
          const SizedBox(height: 10),
          CustomDropdown(
            items: const ["Opción 1", "Opción 2"],
            selectedValue: "Opción 1",
            onChanged: (value) {},
          ),
          const SizedBox(height: 10),
          Checkbox(value: true, onChanged: (val) {}),
          const SizedBox(height: 10),
          Radio(groupValue: "A", value: "A", onChanged: (val) {}),

          const Divider(),

          // 🔹 Tarjetas
          const Text(
            "Cards",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Card(title: "Transporte", subtitle: "Reserva disponible"),
          const SizedBox(height: 10),
          const ProfileCard(name: "Juan Pérez", role: "Estudiante"),

          const Divider(),

          // 🔹 Utils
          const Text(
            "Utils",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const LoadingIndicator(),
          const SizedBox(height: 10),
          const ErrorMessage(message: "Ha ocurrido un error inesperado"),
        ],
      ),
    );
  }
}

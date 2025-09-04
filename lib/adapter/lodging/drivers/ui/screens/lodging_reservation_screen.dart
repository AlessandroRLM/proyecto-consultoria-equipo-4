import 'package:flutter/material.dart';
import 'package:mobile/adapter/core/out/app_themes.dart';

class LodgingReservationScreen extends StatefulWidget {
  const LodgingReservationScreen({super.key});

  @override
  State<LodgingReservationScreen> createState() =>
      _LodgingReservationScreenState();
}

class _LodgingReservationScreenState extends State<LodgingReservationScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> clinics = [
    {
      "name": "Centro Médico Andes Salud Talca",
      "city": "Talca",
      "address": "Cuatro Nte. 1656, 3467384 Talca, Maule",
    },
    {
      "name": "Clínica Santa María",
      "city": "Talca",
      "address": "Calle Falsa 123, Talca, Maule",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reservar")),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: "Buscar campo clínico",
                  border: InputBorder.none,
                  icon: Icon(Icons.search),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                itemCount: clinics.length,
                itemBuilder: (_, index) {
                  final clinic = clinics[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[400]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.local_hospital,
                          color: AppThemes.primary_600,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                clinic["name"]!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(clinic["city"]!),
                              Text(clinic["address"]!),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Abrir mapa
        },
        label: const Text("Buscar en mapa"),
        icon: const Icon(Icons.map),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

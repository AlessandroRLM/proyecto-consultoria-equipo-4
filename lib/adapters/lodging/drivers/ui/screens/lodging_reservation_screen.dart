import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/adapters/core/driven/app_themes.dart';
import 'package:mobile/adapters/lodging/drivers/ui/screens/lodging_map_screen.dart';

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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final text = Theme.of(context).textTheme;

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
                color: theme.brightness == Brightness.light ? AppThemes.black_300 : AppThemes.black_900,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Buscar campo clínico",
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: theme.brightness == Brightness.light ? AppThemes.black_700 : AppThemes.black_400),
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
                  return GestureDetector(
                    onTap: () => context.go('/lodging/calendar', extra: {'selectedLocation': clinic["name"]}),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: cs.outlineVariant),
                        boxShadow: [
                          BoxShadow(
                            color: AppThemes.black_1300.withValues(alpha: 0.1),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
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
                                Text(clinic["name"]!, style: text.titleSmall),
                                Text(clinic["city"]!, style: text.bodySmall),
                                Text(clinic["address"]!, style: text.bodySmall),
                              ],
                            ),
                          ),
                        ],
                      ),
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
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const LodgingMapScreen()),
          );
        },
        label: const Text("Buscar en mapa"),
        icon: const Icon(Icons.map),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

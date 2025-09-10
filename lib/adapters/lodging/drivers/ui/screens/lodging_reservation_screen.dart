import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/adapters/core/driven/app_themes.dart';
import 'package:mobile/domain/core/campus.dart';
import 'package:mobile/ports/core/driven/for_querying_campus.dart';
import 'package:mobile/service_locator.dart';

class LodgingReservationScreen extends StatefulWidget {
  const LodgingReservationScreen({super.key});

  @override
  State<LodgingReservationScreen> createState() =>
      _LodgingReservationScreenState();
}

class _LodgingReservationScreenState extends State<LodgingReservationScreen> {
  final TextEditingController _searchController = TextEditingController();
  final campusService = serviceLocator<ForQueryingCampus>();
  List<Campus> _campusList = [];

  Future<void> _loadCampusData() async {
    final campusList = await campusService.getCampus(null);
    setState(() {
      _campusList = campusList;
    });
  }

  @override
  void initState() {
    super.initState();

    _loadCampusData();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
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
                color: cs.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Buscar campo clínico",
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: cs.onSurfaceVariant),
                ),
                onChanged: (value) async {
                  setState(() {
                    _campusList = [];
                  });
                  if (value == '') {
                    _campusList = await campusService.getCampus(null);
                  }
                  _campusList = await campusService.getCampus(value);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                itemCount: _campusList.length,
                itemBuilder: (context, index) {
                  final clinic = _campusList[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cs.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
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
                              Text(clinic.name, style: text.titleSmall),
                              Text(clinic.city, style: text.bodySmall),
                              Text(clinic.commune, style: text.bodySmall),
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
        onPressed: () =>
            context.push('/lodging_reservation/lodging_map_screen'),
        label: const Text("Buscar en mapa"),
        icon: const Icon(Icons.map),
        heroTag: 'reserve_lodging_map_button',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

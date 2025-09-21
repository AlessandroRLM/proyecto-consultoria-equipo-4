import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/adapters/core/driven/app_themes.dart';
import 'package:mobile/domain/core/campus.dart';
import 'package:mobile/ports/core/driven/for_querying_campus.dart';
import 'package:mobile/service_locator.dart';

class ClinicSelectionScreen extends StatefulWidget {
  // pasar a origin 1 o 2: 1 para transporte y 2 para alojamiento 
  final String? origin;

  const ClinicSelectionScreen({
    required this.origin,
    super.key
    });

  @override
  State<ClinicSelectionScreen> createState() =>
      _ClinicSelectionScreenState();
}

class _ClinicSelectionScreenState extends State<ClinicSelectionScreen> {
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
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Reservar'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
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
                    height: 84,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(clinic.name, style: textTheme.bodyLarge),
                              const SizedBox(width: 4),
                              Text(clinic.city, style: textTheme.bodySmall),
                              const SizedBox(width: 4),
                              Text(clinic.commune, style: textTheme.labelLarge),
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
            context.push('/clinic_map_selection/${widget.origin}'),
        label: Text("Buscar en mapa", style: textTheme.titleMedium!.copyWith(
          color: cs.onPrimary,
        )),
        icon: const Icon(Icons.map),
        heroTag: 'reserve_clinic_map_button',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

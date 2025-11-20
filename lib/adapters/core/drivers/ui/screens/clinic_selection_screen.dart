import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/adapters/core/driven/app_themes.dart';
import 'package:mobile/adapters/transport/driven/providers/transport_reservations_provider.dart';

import 'package:mobile/domain/core/campus.dart';
import 'package:mobile/ports/core/driven/for_querying_campus.dart';
import 'package:mobile/ports/lodging/drivers/for_reserving_lodging.dart';
import 'package:mobile/service_locator.dart';
import 'package:provider/provider.dart';

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
  bool _isNavigating = false;

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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 16.0, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.go(widget.origin == '1' ? '/transport' : '/lodging'),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Reservar',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                  ),
                ],
              ),
            ),
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
                    return GestureDetector(
                      onTap: () async {
                        if (_isNavigating) return;
                        setState(() => _isNavigating = true);
                        try {
                          if (widget.origin == '1') {
                            final provider = Provider.of<TransportReservationsProvider>(context, listen: false);
                            provider.selectedLocation = {
                              'name': clinic.name,
                              'address': '${clinic.commune}, ${clinic.city}',
                              'campus_id': '${clinic.id}',
                              'clinical_id': '${clinic.id}',
                            };
                            await context.push('/transport/time-selection', extra: {'isOutbound': true});
                          } else {
                            final lodgingReservationService = serviceLocator<ForReservingLodging>();
                            lodgingReservationService.campus = clinic; // Guarda la clínica seleccionada

                            context.go('/lodging/calendar'); // Navega al calendario sin pasar extra
                          }

                        } finally {
                          if (mounted) setState(() => _isNavigating = false);
                        }
                      },
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
                                  Text(clinic.name, style: text.titleSmall),
                                  Text(clinic.city, style: text.bodySmall),
                                  Text(clinic.commune, style: text.bodySmall),
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            context.push('/clinic_map_selection/${widget.origin}'),
        label: const Text("Buscar en mapa"),
        icon: const Icon(Icons.map),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

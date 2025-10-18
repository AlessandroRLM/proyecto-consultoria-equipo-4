import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mobile/adapters/core/driven/app_themes.dart';
import 'package:mobile/adapters/core/driven/mapbox_service.dart';
import 'package:mobile/adapters/core/drivers/ui/widgets/map_search_bar.dart';
import 'package:mobile/adapters/core/drivers/ui/widgets/map_results_list.dart';
import 'package:mobile/adapters/core/drivers/ui/widgets/map_control_buttons.dart';
import 'package:mobile/domain/core/campus.dart';
import 'package:mobile/ports/core/driven/for_querying_campus.dart';
import 'package:mobile/ports/core/drivers/for_mapping_interactions.dart';
import 'package:mobile/service_locator.dart';
import 'package:provider/provider.dart';
import 'package:mobile/adapters/transport/driven/providers/transport_reservations_provider.dart';


class ClinicMapScreen extends StatefulWidget {
  // pasar a origin 1 o 2: 1 para transporte y 2 para alojamiento 
  final String? origin;
  
  const ClinicMapScreen({
    this.origin,
    super.key
   });

  @override
  State<ClinicMapScreen> createState() => _ClinicMapScreenState();
}

class _ClinicMapScreenState extends State<ClinicMapScreen>
    implements ForMappingInteractions {
  // Servicioss
  final campusService = serviceLocator<ForQueryingCampus>();
  final mapboxService = serviceLocator<MapboxService>();

  // Estados de UI
  final TextEditingController _searchController = TextEditingController();
  List<Campus> _campusList = [];
  List<Campus> _allCampusList = [];
  bool _isSearching = false;
  bool _showResults = false;

  // Configuracion del Mapa 
  static const double initialLat = -33.4489;
  static const double initialLng = -70.6693;
  late final CameraOptions cameraOptions;

  @override
  void initState() {
    super.initState();
    cameraOptions = CameraOptions(
      center: Point(coordinates: Position(initialLng, initialLat)),
      zoom: 12.0,
    );

    _initializeServices();
    _loadCampusData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    mapboxService.dispose();
    super.dispose();
  }

  // Inicializacion
  Future<void> _initializeServices() async {
    final hasPermission = await mapboxService.requestLocationPermission();

    if (!hasPermission) onLocationPermissionDenied();

  }

  Future<void> _loadCampusData() async {
    final campusList = await campusService.getCampus(null);
    setState(() {
      _campusList = campusList;
      _allCampusList = campusList;
    });
  }


  @override
  void onLocationPermissionDenied() {
    _showPermissionDialog();
  }

  @override
  void onCampusSelected(Campus campus) {
    setState(() {
      _showResults = false;
      _searchController.text = campus.name;
    });
    mapboxService.centerOnCampus(campus);
  }

  @override
  void onSearchResultsChanged(List<Campus> results) {
    setState(() {
      _campusList = results;
    });
  }

  // Event Handlers
  Future<void> _onSearchChanged(String value) async {
    setState(() {
      _isSearching = value.isNotEmpty;
      _showResults = value.isNotEmpty;
    });

    final results = value.isEmpty
        ? await campusService.getCampus(null)
        : await campusService.getCampus(value);

    onSearchResultsChanged(results);
  }

  void _onSearchCleared() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
      _showResults = false;
    });
  }

  void _onCampusMarkerClicked(Campus campus) {
    // Mostrar información del campus en un bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCampusInfoBottomSheet(campus),
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permisos de ubicación'),
        content: const Text(
          'Esta app necesita permisos de ubicación para funcionar correctamente.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _initializeServices();
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildMap(),
          SafeArea(
            child: Column(
              children: [
                MapSearchBar(
                  controller: _searchController,
                  isSearching: _isSearching,
                  onChanged: _onSearchChanged,
                  onClear: _onSearchCleared,
                ),
                if (_showResults)
                  Stack(
                    children: [
                      MapResultsList(
                        campusList: _campusList,
                        onCampusSelected: onCampusSelected,
                      ),
                    ],
                  ),
                const Spacer(),
                MapControlButtons(
                  onZoomIn: mapboxService.zoomIn,
                  onZoomOut: mapboxService.zoomOut,
                  onMyLocation: mapboxService.centerOnUserLocation,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampusInfoBottomSheet(Campus campus) {
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10.0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12.0,
          children: [
            // Botón de cerrar
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: 5,
                width: 65,
                decoration: BoxDecoration(
                  color: AppThemes.black_500,
                  borderRadius: BorderRadius.circular(28.0),
                ),
              ),
            ),
            // Header con ícono y título
            Row(
              spacing: 8,
              children: [
                const Icon(
                  Icons.local_hospital,
                  color: AppThemes.primary_600,
                  size: 24,
                ),
                Expanded(
                  child: Text(
                    campus.name,
                    style: textTheme.bodyLarge
                  ),
                ),
              ],
            ),

            // Información del campus
            Column(
              spacing: 8.0,
              children: [
                _buildInfoRow(Icons.location_city, 'Ciudad', campus.city),
                _buildInfoRow(Icons.place, 'Comuna', campus.commune),
              ],
            ),

            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (widget.origin == '1') {
                        // Guarda la ubicación seleccionada en el Provider
                        final provider = Provider.of<TransportReservationsProvider>(context, listen: false);
                        provider.selectedLocation = {
                          'name': campus.name,
                          'address': '${campus.commune}, ${campus.city}',
                        };
                        await context.push(
                          '/transport/time-selection',
                          extra: {'isOutbound': true},
                        );

                      } else if (widget.origin == '2') {
                        await context.push(
                          '/lodging/calendar',
                          extra: {
                            'selectedLocation': campus.name,
                            'address': campus.commune,
                            'city': campus.city,
                            'residenceName': campus.name,
                            'id': campus.id,
                          },
                        );
                      }
                    },
                    icon: const Icon(Icons.today_outlined, size: 24),
                    label: Text(
                      'Consultar Fechas',
                      style: textTheme.bodyLarge!.copyWith(
                        color: cs.onPrimary,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppThemes.primary_600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),

                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(icon, size: 16,),
        const SizedBox(width: 8.0),
        Text(
          '$label: ',
          style: textTheme.bodyMedium
        ),
        Expanded(
          child: Text(value, style: textTheme.bodyMedium),
        ),
      ],
    );
  }

  Widget _buildMap() {
    final colorScheme = Theme.of(context).colorScheme;

    return MapWidget(
      styleUri: colorScheme.brightness == Brightness.light
          ? MapboxService.mapStyles[0]
          : MapboxService.mapStyles[1],
      cameraOptions: cameraOptions,
      onMapCreated: (MapboxMap mapboxMap) async {
        mapboxService.initialize(mapboxMap);
        await mapboxService.addCampusMarkers(_allCampusList);
        mapboxService.setupMarkerTapEvents(_onCampusMarkerClicked);
      },
    );
  }
}

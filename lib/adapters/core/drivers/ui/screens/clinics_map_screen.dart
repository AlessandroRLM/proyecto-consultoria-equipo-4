import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/adapters/core/driven/app_themes.dart';
import 'package:mobile/adapters/core/drivers/ui/widgets/map_search_bar.dart';
import 'package:mobile/adapters/core/drivers/ui/widgets/map_results_list.dart';
import 'package:mobile/adapters/core/drivers/ui/widgets/map_control_buttons.dart';
import 'package:mobile/adapters/lodging/driven/providers/lodging_provider.dart';
import 'package:mobile/domain/core/campus.dart';
import 'package:mobile/ports/core/driven/for_querying_campus.dart';
import 'package:mobile/ports/core/driven/for_managing_map.dart';
import 'package:mobile/ports/core/driven/for_managing_location.dart';
import 'package:mobile/ports/core/drivers/for_interacting_map.dart';
import 'package:mobile/service_locator.dart';
import 'package:provider/provider.dart';
import 'package:mobile/adapters/transport/driven/providers/transport_reservations_provider.dart';

class ClinicMapScreen extends StatefulWidget {
  /// Origen de la navegación: 1 para transporte, 2 para alojamiento
  final String? origin;

  const ClinicMapScreen({
    this.origin,
    super.key,
  });

  @override
  State<ClinicMapScreen> createState() => _ClinicMapScreenState();
}

class _ClinicMapScreenState extends State<ClinicMapScreen>
    implements ForInteractingMap {
  // Servicios - Usando puertos en lugar de implementaciones concretas
  late final ForQueryingCampus _campusService;
  late final ForManagingMap _mapService;
  late final ForManagingLocation _locationService;

  // Estados de UI
  final TextEditingController _searchController = TextEditingController();
  List<Campus> _campusList = [];
  List<Campus> _allCampusList = [];
  bool _isSearching = false;
  bool _showResults = false;

  // Configuración del Mapa
  static const double initialLat = -33.4489;
  static const double initialLng = -70.6693;

  @override
  void initState() {
    super.initState();

    // Obtener servicios del service locator
    _campusService = serviceLocator<ForQueryingCampus>();
    _mapService = serviceLocator<ForManagingMap>();
    _locationService = serviceLocator<ForManagingLocation>();

    _initializeServices();
    _loadCampusData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapService.dispose();
    super.dispose();
  }

  // Inicialización
  Future<void> _initializeServices() async {
    try {
      // Usar el servicio de ubicación para verificar disponibilidad
      final isLocationAvailable = await _locationService.isLocationAvailable();

      if (!isLocationAvailable) {
        onLocationPermissionDenied();
      }
    } catch (e) {
      debugPrint('Error al inicializar servicios: $e');
      onLocationPermissionDenied();
    }
  }

  Future<void> _loadCampusData() async {
    try {
      final campusList = await _campusService.getCampus(null);
      setState(() {
        _campusList = campusList;
        _allCampusList = campusList;
      });
    } catch (e) {
      debugPrint('Error al cargar datos de campus: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cargar los campus clínicos'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Implementación de ForInteractingMap
  @override
  void onLocationPermissionDenied() {
    if (mounted) {
      _showPermissionDialog();
    }
  }

  @override
  void onCampusSelected(Campus campus) {
    setState(() {
      _showResults = false;
      _searchController.text = campus.name;
    });
    _mapService.centerOnCampus(campus);
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

    try {
      final results = value.isEmpty
          ? await _campusService.getCampus(null)
          : await _campusService.getCampus(value);

      onSearchResultsChanged(results);
    } catch (e) {
      debugPrint('Error al buscar campus: $e');
    }
  }

  void _onSearchCleared() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
      _showResults = false;
    });
    
    // Restaurar lista completa
    onSearchResultsChanged(_allCampusList);
  }

  void _onCampusMarkerClicked(Campus campus) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCampusInfoBottomSheet(campus),
    );
  }

  Future<void> _onMyLocationPressed() async {
    try {
      await _mapService.centerOnUserLocation();
    } catch (e) {
      debugPrint('Error al centrar en ubicación del usuario: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo obtener tu ubicación'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permisos de ubicación'),
        content: const Text(
          'Esta app necesita permisos de ubicación para mostrarte tu posición en el mapa.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
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
                  MapResultsList(
                    campusList: _campusList,
                    onCampusSelected: onCampusSelected,
                  ),
                const Spacer(),
                MapControlButtons(
                  onZoomIn: _mapService.zoomIn,
                  onZoomOut: _mapService.zoomOut,
                  onMyLocation: _onMyLocationPressed,
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
        borderRadius: const BorderRadius.only(
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
          children: [
            // Barra indicadora
            Center(
              child: Container(
                height: 5,
                width: 65,
                decoration: BoxDecoration(
                  color: AppThemes.black_500,
                  borderRadius: BorderRadius.circular(28.0),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Header con ícono y título
            Row(
              children: [
                const Icon(
                  Icons.local_hospital,
                  color: AppThemes.primary_600,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    campus.name,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Información del campus
            _buildInfoRow(Icons.location_city, 'Ciudad', campus.city),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.place, 'Comuna', campus.commune),
            const SizedBox(height: 16),

            // Botón de acción
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _handleCampusSelection(campus),
                icon: const Icon(Icons.today_outlined, size: 24),
                label: Text(
                  'Consultar Fechas',
                  style: textTheme.bodyLarge?.copyWith(
                    color: cs.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppThemes.primary_600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
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
        Icon(icon, size: 16, color: AppThemes.primary_600),
        const SizedBox(width: 8.0),
        Text(
          '$label: ',
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Future<void> _handleCampusSelection(Campus campus) async {
    // Cerrar el bottom sheet
    if (mounted) Navigator.pop(context);

    try {
      if (widget.origin == '1') {
        // Flujo de transporte
        final provider = Provider.of<TransportReservationsProvider>(
          context,
          listen: false,
        );
        provider.selectedLocation = {
          'name': campus.name,
          'address': '${campus.commune}, ${campus.city}',
          'campus_id': '${campus.id}',
          'clinical_id': '${campus.id}',
        };
        
        if (mounted) {
          await context.push(
            '/transport/time-selection',
            extra: {'isOutbound': true},
          );
        }
      } else if (widget.origin == '2') {
        // Flujo de alojamiento
        final lodgingProvider = Provider.of<LodgingProvider>(
          context,
          listen: false,
        );
        lodgingProvider.selectClinic(campus);
        
        if (mounted) {
          context.go('/lodging/calendar');
        }
      }
    } catch (e) {
      debugPrint('Error al manejar selección de campus: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al procesar la selección'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildMap() {
    final colorScheme = Theme.of(context).colorScheme;
    
    // Obtener estilos disponibles del proveedor
    final availableStyles = _mapService.getAvailableStyles();
    final selectedStyle = colorScheme.brightness == Brightness.light
        ? availableStyles[0]  // Estilo claro
        : availableStyles[1]; // Estilo oscuro

    // Usar el widget provider con configuración completa
    return _mapService.buildMapWidget(
      onMapCreated: _onMapCreated,
      styleUri: selectedStyle,
      initialZoom: 12.0,
      initialLatitude: initialLat,
      initialLongitude: initialLng,
    );
  }

  Future<void> _onMapCreated(dynamic mapInstance) async {
    try {
      // Inicializar el servicio de mapa con la instancia
      _mapService.initialize(mapInstance);

      // Agregar marcadores de campus
      if (_allCampusList.isNotEmpty) {
        await _mapService.addCampusMarkers(_allCampusList);
      }

      // Configurar eventos de tap en marcadores
      _mapService.setupMarkerTapEvents(_onCampusMarkerClicked);

      // Centrar en ubicación del usuario si está disponible
      try {
        final hasLocation = await _locationService.isLocationAvailable();
        if (hasLocation) {
          await _mapService.centerOnUserLocation(zoom: 12.0);
        }
      } catch (e) {
        debugPrint('No se pudo centrar en ubicación del usuario: $e');
        // No es crítico, el mapa se mostrará en la ubicación inicial
      }
    } catch (e) {
      debugPrint('Error al configurar el mapa: $e');
    }
  }
}

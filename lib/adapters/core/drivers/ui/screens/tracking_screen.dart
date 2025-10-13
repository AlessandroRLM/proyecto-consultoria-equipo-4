import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mobile/adapters/core/driven/mapbox_service.dart';
import 'package:mobile/adapters/core/drivers/ui/widgets/map_control_buttons.dart';
import 'package:mobile/service_locator.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/adapters/core/driven/app_themes.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final mapboxService = serviceLocator<MapboxService>();
  late final CameraOptions cameraOptions;
  bool _tracking = false;

  static const double initialLat = -33.424644;
  static const double initialLng = -70.611964;

  @override
  void initState() {
    super.initState();
    cameraOptions = CameraOptions(
      center: Point(coordinates: Position(initialLng, initialLat)),
      zoom: 12.0,
    );
    _initializeServices();
  }

  @override
  void dispose() {
    mapboxService.dispose();
    super.dispose();
  }

  Future<void> _initializeServices() async {
    final hasPermission = await mapboxService.requestLocationPermission();
    if (!hasPermission && mounted) {
      _showPermissionDialog();
    }
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
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          _buildMap(),
          // Botón volver en esquina superior izquierda
          Positioned(
            top: 16,
            left: 16,
            child: SafeArea(
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: AppThemes.primary_600, width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4.0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.arrow_back, color: AppThemes.primary_600),
                  onPressed: () => context.go('/transport'),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const Spacer(),
                MapControlButtons(
                  onZoomIn: mapboxService.zoomIn,
                  onZoomOut: mapboxService.zoomOut,
                  onMyLocation: mapboxService.centerOnUserLocation,
                ),
                Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: _DriverInfoCard(
              vehicle: 'Toyota Hiace',
              plate: 'HHJK90',
              service: 'Ambulancia',
              driverName: 'Miguel Herrera',
              clinicName: 'Universidad Autónoma de Chile',
              departureTime: '10:00AM',
            ),
          ),
              ],
            ),
          ),
        ],
      ),
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
        await mapboxService.centerOnUserLocation();
        // Auto-iniciar tracking y dibujar ruta al destino
        final route = _mockRoute();
        await mapboxService.startSimulatedVehicleTracking(
          route,
          follow: true,
          intervalMs: 5000,
          iconSize: 0.2,
        );
        // Define destino (clínica) para polilínea automática
        final dest = Position(-70.610969, -33.427440);
        mapboxService.setRouteDestination(dest);
        if (mounted) setState(() => _tracking = true);
      },
    );
  }

  List<Position> _mockRoute() {
    return [
      Position(initialLng, initialLat),
      Position(-70.611801, -33.425172),
      Position(-70.611500, -33.426012),
      Position(-70.611269, -33.426634),
      Position(-70.611066, -33.427211),
      Position(-70.610969, -33.427440),
    ];
  }
}

class _DriverInfoCard extends StatelessWidget {
  final String vehicle;
  final String plate;
  final String service;
  final String driverName;
  final String clinicName;
  final String departureTime;

  const _DriverInfoCard({
    required this.vehicle,
    required this.plate,
    required this.service,
    required this.driverName,
    required this.clinicName,
    required this.departureTime,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      color: theme.colorScheme.surface,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: theme.colorScheme.surface,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                          Icons.directions_bus_filled,
                          color: theme.colorScheme.primary,
                          size: 28),
                          const SizedBox(width: 8),
                          Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$vehicle - $plate',
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700,height: 2.0),
                              ),
                              Text(
                              '$service - $driverName',
                              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7))),
                          ])])
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                Icon(Icons.home_work_rounded, size: 18, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Centro Clínico: $clinicName',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.access_time_rounded, size: 18, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                const SizedBox(width: 8),
                Text(
                  'Hora de salida: $departureTime',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

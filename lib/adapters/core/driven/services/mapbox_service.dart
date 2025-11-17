// adapters/core/driven/mapbox_map_adapter.dart

import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mobile/adapters/core/driven/app_themes.dart';
import 'package:mobile/domain/core/user_location.dart';
import 'package:mobile/domain/core/campus.dart';
import 'package:mobile/ports/core/driven/for_managing_map.dart';
import 'package:mobile/ports/core/driven/for_managing_location.dart';

/// Adaptador de Mapbox que implementa los puertos de mapa
/// Esta es la implementación concreta para Mapbox
class MapboxMapService implements ForManagingMap {
  MapboxMap? _mapboxMap;
  final ForManagingLocation _locationRepository;
  PointAnnotationManager? _userLocationManager;
  PointAnnotationManager? _campusMarkersManager;
  final List<PointAnnotation> _campusAnnotations = [];
  Cancelable? _tapEventsCancelable;
  Map<PointAnnotation, Campus> _campusAnnotationMap = {};

  static const List<String> _mapStyles = [
    MapboxStyles.LIGHT,
    MapboxStyles.DARK
  ];

  // Inyección de dependencia del servicio de ubicación
  MapboxMapService({required ForManagingLocation locationService})
      : _locationRepository = locationService;

  @override
  void initialize(dynamic mapInstance) {
    if (mapInstance is! MapboxMap) {
      throw ArgumentError('mapInstance debe ser de tipo MapboxMap');
    }
    _mapboxMap = mapInstance;
    _initializeCustomIcons();
    _setupLocationComponent();
  }

  @override
  Future<bool> requestLocationPermission() async {
    return await _locationRepository.isLocationAvailable();
  }

  Future<void> _setupLocationComponent() async {
    if (_mapboxMap == null) return;

    try {
      await _mapboxMap!.location.updateSettings(
        LocationComponentSettings(
          enabled: true,
          showAccuracyRing: true,
          pulsingEnabled: true,
          pulsingColor: AppThemes.primary_600.toARGB32(),
          pulsingMaxRadius: 20,
          locationPuck: LocationPuck(
            locationPuck2D: LocationPuck2D(
              topImage: await _createLocationPuckIcon(),
            ),
          ),
        ),
      );
      debugPrint('Componente de ubicación de Mapbox configurado');
    } catch (e) {
      debugPrint('Error al configurar el componente de ubicación de Mapbox: $e');
    }
  }

  Future<void> _initializeCustomIcons() async {
    if (_mapboxMap == null) return;

    try {
      final hospitalIconBytes = await _createHospitalIcon();
      final hospitalImage = MbxImage(
        width: 48,
        height: 56,
        data: hospitalIconBytes,
      );

      await _mapboxMap!.style.addStyleImage(
        "hospital-marker",
        1.0,
        hospitalImage,
        false,
        [],
        [],
        null,
      );
    } catch (e) {
      debugPrint('Error creando íconos personalizados: $e');
    }
  }

  Future<Uint8List> _createLocationPuckIcon() async {
    final ByteData bytes = await rootBundle.load(
        'assets/images/location_puck/location_puck.png');
    return bytes.buffer.asUint8List();
  }

  Future<Uint8List> _createHospitalIcon() async {
    const size = 48.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..isAntiAlias = true;

    final path = Path();
    path.addOval(
      Rect.fromCircle(center: Offset(size / 2, size / 2 - 8), radius: 16),
    );
    path.moveTo(size / 2 - 8, size / 2 + 4);
    path.lineTo(size / 2, size / 2 + 16);
    path.lineTo(size / 2 + 8, size / 2 + 4);
    path.close();

    paint.color = Colors.black26;
    canvas.drawPath(path.shift(const Offset(2, 2)), paint);

    paint.color = AppThemes.primary_600;
    canvas.drawPath(path, paint);

    paint.color = Colors.white;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawPath(path, paint);

    paint.style = PaintingStyle.fill;
    paint.color = Colors.white;

    canvas.drawRect(Rect.fromLTWH(size / 2 - 8, size / 2 - 10, 16, 4), paint);
    canvas.drawRect(Rect.fromLTWH(size / 2 - 2, size / 2 - 16, 4, 16), paint);

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), (size + 8).toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  @override
  Future<void> addCampusMarkers(List<Campus> campusList) async {
    if (_mapboxMap == null) return;

    try {
      _campusMarkersManager =
          await _mapboxMap!.annotations.createPointAnnotationManager();

      final Map<PointAnnotation, Campus> annotationToCampusMap = {};

      for (final campus in campusList) {
        final point = Point(
          coordinates: Position(campus.longitude, campus.latitude),
        );

        final annotation = await _campusMarkersManager?.create(
          PointAnnotationOptions(
            geometry: point,
            iconImage: "hospital-marker",
            iconSize: 1,
          ),
        );

        if (annotation != null) {
          _campusAnnotations.add(annotation);
          annotationToCampusMap[annotation] = campus;
        }
      }

      _campusAnnotationMap = annotationToCampusMap;
    } catch (e) {
      debugPrint('Error creando manager de marcadores de campus: $e');
    }
  }

  @override
  Future<void> filterCampusMarkers(List<Campus> filteredCampusList) async {
    await addCampusMarkers(filteredCampusList);
  }

  @override
  Future<void> centerOnLocation(
    UserLocation location, {
    double zoom = 14.0,
  }) async {
    if (_mapboxMap == null) return;

    await _mapboxMap!.flyTo(
      CameraOptions(
        center: Point(
          coordinates: Position(location.longitude, location.latitude),
        ),
        zoom: zoom,
      ),
      MapAnimationOptions(duration: 1000),
    );
  }

  @override
  Future<void> centerOnCampus(Campus campus, {double zoom = 14.0}) async {
    if (_mapboxMap == null) return;

    await _mapboxMap!.flyTo(
      CameraOptions(
        center: Point(coordinates: Position(campus.longitude, campus.latitude)),
        zoom: zoom,
      ),
      MapAnimationOptions(duration: 1000),
    );
  }

  @override
  Future<void> centerOnUserLocation({double zoom = 14.0}) async {
    if (_mapboxMap == null) return;
    try {
      // Usar el servicio de ubicación inyectado
      final location = await _locationRepository.getCurrentLocation();

      await _mapboxMap!.flyTo(
        CameraOptions(
          center: Point(
            coordinates: Position(location.longitude, location.latitude),
          ),
          zoom: zoom,
        ),
        MapAnimationOptions(duration: 500),
      );
    } catch (e) {
      debugPrint('Error centrando mapa en ubicación del usuario: $e');
    }
  }

  @override
  void setupMarkerTapEvents(Function(Campus) onCampusMarkerTapped) {
    _tapEventsCancelable?.cancel();

    if (_campusMarkersManager == null) return;

    _tapEventsCancelable = _campusMarkersManager!.tapEvents(
      onTap: (PointAnnotation annotation) {
        final campus = _campusAnnotationMap[annotation];
        if (campus != null) {
          onCampusMarkerTapped(campus);
        }
      },
    );
  }

  @override
  Future<void> zoomIn() async {
    if (_mapboxMap == null) return;

    final currentZoom = await _mapboxMap!.getCameraState().then(
      (value) => value.zoom,
    );
    _mapboxMap!.setCamera(CameraOptions(zoom: currentZoom + 1));
  }

  @override
  Future<void> zoomOut() async {
    if (_mapboxMap == null) return;

    final currentZoom = await _mapboxMap!.getCameraState().then(
      (value) => value.zoom,
    );
    _mapboxMap!.setCamera(CameraOptions(zoom: currentZoom - 1));
  }

  @override
  Future<void> dispose() async {
    _tapEventsCancelable?.cancel();
    try {
      if (_userLocationManager != null) {
        await _mapboxMap?.annotations.removeAnnotationManager(
          _userLocationManager!,
        );
      }
      if (_campusMarkersManager != null) {
        await _mapboxMap?.annotations.removeAnnotationManager(
          _campusMarkersManager!,
        );
      }
    } catch (e) {
      debugPrint('Error al limpiar managers de Mapbox: $e');
    }
  }

  // Implementación de ForProvidingMapWidget
  @override
  Widget buildMapWidget({
    required Function(dynamic) onMapCreated,
    Widget? child,
    String? styleUri,
    double? initialZoom,
    double? initialLatitude,
    double? initialLongitude,
  }) {
    return MapWidget(
      key: const ValueKey("mapWidget"),
      styleUri: styleUri ?? _mapStyles[0],
      cameraOptions: CameraOptions(
        center: Point(
          coordinates: Position(
            initialLongitude ?? -70.6693,
            initialLatitude ?? -33.4489,
          ),
        ),
        zoom: initialZoom ?? 12.0,
      ),
      onMapCreated: onMapCreated,
    );
  }

  @override
  List<String> getAvailableStyles() {
    return _mapStyles;
  }
}
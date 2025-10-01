import 'dart:async';
import 'dart:ui' as ui;
import 'package:location/location.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/adapters/core/driven/app_themes.dart';
import 'package:mobile/domain/core/user_location.dart';
import 'package:mobile/domain/core/campus.dart';

class MapboxService {
  MapboxMap? _mapboxMap;
  final Location _location = Location();
  PointAnnotationManager? _userLocationManager;
  PointAnnotationManager? _campusMarkersManager;
  final List<PointAnnotation> _campusAnnotations = [];
  Cancelable? _tapEventsCancelable; // Para manejar la suscripción a eventos
  Map<PointAnnotation, Campus> _campusAnnotationMap =
      {}; // Mapeo de anotaciones a campus

  static const List<String> mapStyles = [MapboxStyles.LIGHT, MapboxStyles.DARK];

  void initialize(MapboxMap mapboxMap) {
    _mapboxMap = mapboxMap;
    _initializeCustomIcons();
    _setupLocationComponent();
  }

  Future<bool> requestLocationPermission() async {
    try {
      // Verificar primero si el servicio de ubicación está habilitado
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          print('Servicio de ubicación no está habilitado');
          return false;
        }
      }

      // Verificar permisos usando el paquete location
      PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          print('Permisos de ubicación denegados');
          return false;
        }
      }

      print('Permisos y servicios de ubicación configurados correctamente');
      return permissionGranted == PermissionStatus.granted;
    } catch (e) {
      print('Error al solicitar permisos de ubicación: $e');
      return false;
    }
  }

  /// Configura el componente de ubicación nativo de Mapbox
  Future<void> _setupLocationComponent() async {
    if (_mapboxMap == null) return;

    try {
      // Configurar el componente de ubicación de Mapbox
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

      print('Componente de ubicación de Mapbox configurado');
    } catch (e) {
      print('Error al configurar el componente de ubicación de Mapbox: $e');
    }
  }

  /// Inicializa los íconos personalizados para el mapa
  Future<void> _initializeCustomIcons() async {
    if (_mapboxMap == null) return;

    try {
      // Crear ícono personalizado para hospitales/clínicas
      final hospitalIconBytes = await _createHospitalIcon();
      final hospitalImage = MbxImage(
        width: 48,
        height: 56, // Altura mayor por la forma de gota
        data: hospitalIconBytes,
      );

      await _mapboxMap!.style.addStyleImage(
        "hospital-marker", // imageId
        1.0, // scale
        hospitalImage, // image (MbxImage)
        false, // sdf
        [], // stretchX
        [], // stretchY
        null, // content
      );
    } catch (e) {
      print('Error creando íconos personalizados: $e');
    }
  }

  Future<Uint8List> _createLocationPuckIcon() async {
    final ByteData bytes = await rootBundle.load(
      'assets/images/location_puck/location_puck.png'
    );
    return bytes.buffer.asUint8List();
  }

  /// Crea un ícono personalizado para hospitales/clínicas
  Future<Uint8List> _createHospitalIcon() async {
    const size = 48.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..isAntiAlias = true;

    // Fondo del marcador
    final path = Path();
    path.addOval(
      Rect.fromCircle(center: Offset(size / 2, size / 2 - 8), radius: 16),
    );
    path.moveTo(size / 2 - 8, size / 2 + 4);
    path.lineTo(size / 2, size / 2 + 16);
    path.lineTo(size / 2 + 8, size / 2 + 4);
    path.close();

    // Sombra
    paint.color = Colors.black26;
    canvas.drawPath(path.shift(const Offset(2, 2)), paint);

    // Fondo principal
    paint.color = AppThemes.primary_600; // Azul médico
    canvas.drawPath(path, paint);

    // Borde
    paint.color = Colors.white;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawPath(path, paint);

    // Ícono de hospital (cruz médica)
    paint.style = PaintingStyle.fill;
    paint.color = Colors.white;

    // Cruz horizontal
    canvas.drawRect(Rect.fromLTWH(size / 2 - 8, size / 2 - 10, 16, 4), paint);

    // Cruz vertical
    canvas.drawRect(Rect.fromLTWH(size / 2 - 2, size / 2 - 16, 4, 16), paint);

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), (size + 8).toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  /// Agrega todos los marcadores de campus al mapa
  Future<void> addCampusMarkers(List<Campus> campusList) async {
    if (_mapboxMap == null) return;

    // Crear manager para campus si no existe
    try {
      _campusMarkersManager = await _mapboxMap!.annotations
          .createPointAnnotationManager();

      // Agregar nuevos marcadores y crear un mapa para búsqueda rápida
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

      // Almacenar la referencia para usar en los eventos de tap
      _campusAnnotationMap = annotationToCampusMap;
    } catch (e) {
      print('Error creando manager de marcadores de campus: $e');
    }
  }

  /// Filtra los marcadores de campus basado en una búsqueda
  Future<void> filterCampusMarkers(List<Campus> filteredCampusList) async {
    await addCampusMarkers(filteredCampusList);
  }

  /// Centra el mapa en una ubicación específica
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

  /// Centra el mapa en un campus específico
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

  /// Centra el mapa en la ubicación del usuario
  Future<void> centerOnUserLocation({double zoom = 14.0}) async {
    if (_mapboxMap == null) return;
    try {
      final location = await _location.getLocation();

      await _mapboxMap!.flyTo(
        CameraOptions(
          center: Point(
            coordinates: Position(location.longitude!, location.latitude!),
          ),
          zoom: zoom,
        ),
        MapAnimationOptions(duration: 500),
      );
    } catch (e) {
      print('Error centrando mapa en ubicación del usuario: $e');
    }
  }

  /// Configura eventos de tap en los marcadores usando la nueva API
  void setupMarkerTapEvents(Function(Campus) onCampusMarkerTapped) {
    // Cancelar eventos anteriores si existen
    _tapEventsCancelable?.cancel();

    if (_campusMarkersManager == null) return;

    // Configurar nuevos eventos de tap
    _tapEventsCancelable = _campusMarkersManager!.tapEvents(
      onTap: (PointAnnotation annotation) {
        // Buscar el campus asociado a esta anotación
        final campus = _campusAnnotationMap[annotation];
        if (campus != null) {
          onCampusMarkerTapped(campus);
        }
      },
    );
  }

  /// Aumenta el zoom del mapa
  Future<void> zoomIn() async {
    if (_mapboxMap == null) return;

    final currentZoom = await _mapboxMap!.getCameraState().then(
      (value) => value.zoom,
    );
    _mapboxMap!.setCamera(CameraOptions(zoom: currentZoom + 1));
  }

  /// Disminuye el zoom del mapa
  Future<void> zoomOut() async {
    if (_mapboxMap == null) return;

    final currentZoom = await _mapboxMap!.getCameraState().then(
      (value) => value.zoom,
    );
    _mapboxMap!.setCamera(CameraOptions(zoom: currentZoom - 1));
  }

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
      print('Error al limpiar managers de Mapbox: $e');
    }
  }
}

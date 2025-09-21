import 'dart:async';
import 'dart:ui' as ui;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/adapters/core/driven/app_themes.dart';
import 'package:mobile/domain/core/user_location.dart';
import 'package:mobile/domain/core/campus.dart';

class MapboxService {
  MapboxMap? _mapboxMap;
  PointAnnotationManager? _userLocationManager;
  PointAnnotationManager? _campusMarkersManager;
  PointAnnotation? _userLocationAnnotation;
  final List<PointAnnotation> _campusAnnotations = [];
  Cancelable? _tapEventsCancelable; // Para manejar la suscripción a eventos
  Map<PointAnnotation, Campus> _campusAnnotationMap = {}; // Mapeo de anotaciones a campus

  static const String defaultMapStyle = 'mapbox://styles/alessandrorlm/cmfbxp33m000d01s4az8dbz68';

  void initialize(MapboxMap mapboxMap) {
    _mapboxMap = mapboxMap;
    _initializeCustomIcons();
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
        "hospital-marker",     // imageId
        1.0,                   // scale
        hospitalImage,         // image (MbxImage)
        false,                 // sdf
        [],                    // stretchX
        [],                    // stretchY
        null,                  // content
      );

      // Crear ícono personalizado para ubicación del usuario
      final userIconBytes = await _createUserLocationIcon();
      final userImage = MbxImage(
        width: 32,
        height: 32,
        data: userIconBytes,
      );
      
      await _mapboxMap!.style.addStyleImage(
        "user-location",       // imageId
        1.0,                   // scale
        userImage,             // image (MbxImage)
        false,                 // sdf
        [],                    // stretchX
        [],                    // stretchY
        null,                  // content
      );
    } catch (e) {
      print('Error creando íconos personalizados: $e');
    }
  }

  /// Crea un ícono personalizado para hospitales/clínicas
  Future<Uint8List> _createHospitalIcon() async {
    const size = 48.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..isAntiAlias = true;

    // Fondo del marcador
    final path = Path();
    path.addOval(Rect.fromCircle(center: Offset(size/2, size/2 - 8), radius: 16));
    path.moveTo(size/2 - 8, size/2 + 4);
    path.lineTo(size/2, size/2 + 16);
    path.lineTo(size/2 + 8, size/2 + 4);
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
    canvas.drawRect(
      Rect.fromLTWH(size/2 - 8, size/2 - 10, 16, 4),
      paint,
    );
    
    // Cruz vertical
    canvas.drawRect(
      Rect.fromLTWH(size/2 - 2, size/2 - 16, 4, 16),
      paint,
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), (size + 8).toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  /// Crea un ícono personalizado para la ubicación del usuario
  Future<Uint8List> _createUserLocationIcon() async {
    const size = 32.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..isAntiAlias = true;

    final center = Offset(size/2, size/2);

    // Sombra
    paint.color = Colors.black26;
    canvas.drawCircle(center.translate(1, 1), 12, paint);

    // Borde exterior
    paint.color = Colors.white;
    canvas.drawCircle(center, 12, paint);

    // Círculo interior azul
    paint.color = AppThemes.primary_600;
    canvas.drawCircle(center, 8, paint);

    // Punto central
    paint.color = Colors.white;
    canvas.drawCircle(center, 3, paint);

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  /// Actualiza la ubicación del usuario en el mapa
  Future<void> updateUserLocation(UserLocation location) async {
    if (_mapboxMap == null) return;

    final point = Point(
      coordinates: Position(location.longitude, location.latitude)
    );

    // Crear manager para ubicación del usuario si no existe
    _userLocationManager ??= await _mapboxMap!.annotations.createPointAnnotationManager();

    // Eliminar anotación anterior si existe
    if (_userLocationAnnotation != null) {
      await _userLocationManager!.delete(_userLocationAnnotation!);
    }

    // Crear nueva anotación de usuario
    _userLocationAnnotation = await _userLocationManager!.create(
      PointAnnotationOptions(
        geometry: point,
        iconImage: "user-location",
        iconSize: 1.0,
      ),
    );
  }

  /// Agrega todos los marcadores de campus al mapa
  Future<void> addCampusMarkers(List<Campus> campusList) async {
    if (_mapboxMap == null) return;

    // Crear manager para campus si no existe
    _campusMarkersManager ??= await _mapboxMap!.annotations.createPointAnnotationManager();

    // Limpiar marcadores existentes
    await _clearCampusMarkers();

    // Agregar nuevos marcadores y crear un mapa para búsqueda rápida
    final Map<PointAnnotation, Campus> annotationToCampusMap = {};
    
    for (final campus in campusList) {
      final point = Point(
        coordinates: Position(campus.longitude, campus.latitude)
      );

      final annotation = await _campusMarkersManager?.create(
        PointAnnotationOptions(
          geometry: point,
          iconImage: "hospital-marker",
          iconSize: 0.8,
        ),
      );

      if (annotation != null) {
        _campusAnnotations.add(annotation);
        annotationToCampusMap[annotation] = campus;
      }
    }

    // Almacenar la referencia para usar en los eventos de tap
    _campusAnnotationMap = annotationToCampusMap;
  }


  /// Limpia todos los marcadores de campus
  Future<void> _clearCampusMarkers() async {
    if (_campusMarkersManager == null) return;

    for (final annotation in _campusAnnotations) {
      await _campusMarkersManager!.delete(annotation);
    }
    _campusAnnotations.clear();
  }

  /// Filtra los marcadores de campus basado en una búsqueda
  Future<void> filterCampusMarkers(List<Campus> filteredCampusList) async {
    await addCampusMarkers(filteredCampusList);
  }

  /// Centra el mapa en una ubicación específica
  Future<void> centerOnLocation(UserLocation location, {double zoom = 16.0}) async {
    if (_mapboxMap == null) return;

    await _mapboxMap!.flyTo(
      CameraOptions(
        center: Point(
          coordinates: Position(location.longitude, location.latitude)
        ),
        zoom: zoom,
      ),
      MapAnimationOptions(duration: 1000),
    );
  }

  /// Centra el mapa en un campus específico
  Future<void> centerOnCampus(Campus campus, {double zoom = 15.0}) async {
    if (_mapboxMap == null) return;

    await _mapboxMap!.flyTo(
      CameraOptions(
        center: Point(
          coordinates: Position(campus.longitude, campus.latitude)
        ),
        zoom: zoom,
      ),
      MapAnimationOptions(duration: 1000),
    );
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

  /// Limpia todos los recursos
  void dispose() {
    // Cancelar eventos de tap
    _tapEventsCancelable?.cancel();
    
    // Limpiar managers
    if (_userLocationManager != null) {
      _mapboxMap?.annotations.removeAnnotationManager(_userLocationManager!);
    }
    if (_campusMarkersManager != null) {
      _mapboxMap?.annotations.removeAnnotationManager(_campusMarkersManager!);
    }
    
    // Limpiar listas y mapas
    _campusAnnotations.clear();
    _campusAnnotationMap.clear();
  }
}


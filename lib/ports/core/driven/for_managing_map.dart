import 'package:flutter/material.dart';
import 'package:mobile/domain/core/user_location.dart';
import 'package:mobile/domain/core/campus.dart';

/// Puerto para gestionar operaciones del mapa
abstract class ForManagingMap {
  /// Inicializa el servicio de mapa con el objeto específico del proveedor
  void initialize(dynamic mapInstance);

  /// Solicita permisos de ubicación al usuario
  Future<bool> requestLocationPermission();

  /// Agrega marcadores de campus al mapa
  Future<void> addCampusMarkers(List<Campus> campusList);

  /// Filtra los marcadores de campus basado en una lista
  Future<void> filterCampusMarkers(List<Campus> filteredCampusList);

  /// Centra el mapa en una ubicación específica
  Future<void> centerOnLocation(UserLocation location, {double zoom = 14.0});

  /// Centra el mapa en un campus específico
  Future<void> centerOnCampus(Campus campus, {double zoom = 14.0});

  /// Centra el mapa en la ubicación del usuario
  Future<void> centerOnUserLocation({double zoom = 14.0});

  /// Configura eventos de tap en los marcadores
  void setupMarkerTapEvents(Function(Campus) onCampusMarkerTapped);

  /// Aumenta el zoom del mapa
  Future<void> zoomIn();

  /// Disminuye el zoom del mapa
  Future<void> zoomOut();

  /// Agrega un marcador genérico en una ubicación
  ///
  /// [latitude] y [longitude] indican la posición.
  /// [id] y [label] son opcionales para que la implementación pueda
  /// identificar el marcador o mostrar un texto.
  Future<void> addMarker({
    required double latitude,
    required double longitude,
    String? id,
    String? label,
  });

  /// Retorna el widget de mapa específico del proveedor
  /// [onMapCreated] callback que se ejecuta cuando el mapa está listo
  /// [styleUri] URI del estilo del mapa (opcional)
  /// [initialZoom] nivel de zoom inicial (opcional)
  /// [initialLatitude] latitud inicial (opcional)
  /// [initialLongitude] longitud inicial (opcional)
  /// [child] widget hijo que se superpone al mapa (opcional)
  Widget buildMapWidget({
    required Function(dynamic) onMapCreated,
    Widget? child,
    String? styleUri,
    double? initialZoom,
    double? initialLatitude,
    double? initialLongitude,
  });

  /// Retorna los estilos disponibles para este proveedor de mapas
  List<String> getAvailableStyles();

  /// Libera recursos del servicio
  Future<void> dispose();
}

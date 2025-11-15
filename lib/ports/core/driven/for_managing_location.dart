import 'package:mobile/domain/core/user_location.dart';

/// Estado de los permisos de ubicación
enum LocationPermissionStatus {
  granted,
  denied,
  deniedForever,
  whileInUse,
}

/// Estado del servicio de ubicación
enum LocationServiceStatus {
  enabled,
  disabled,
}

/// Puerto para localizar el dispositivo.
abstract class ForManagingLocation {
  /// Verifica si el servicio de ubicación está habilitado
  Future<LocationServiceStatus> checkServiceStatus();

  /// Solicita habilitar el servicio de ubicación
  Future<LocationServiceStatus> requestServiceEnable();

  /// Verifica el estado actual de los permisos de ubicación
  Future<LocationPermissionStatus> checkPermissionStatus();

  /// Solicita permiso para acceder a la localización del dispositivo.
  Future<LocationPermissionStatus> requestPermission();

  /// Obtiene la ubicación actual del usuario
  /// Lanza excepción si no hay permisos o el servicio está deshabilitado
  Future<UserLocation> getCurrentLocation();

  /// Verifica si los permisos y servicios están configurados correctamente
  /// Retorna true si todo está listo para obtener ubicación
  Future<bool> isLocationAvailable();

}




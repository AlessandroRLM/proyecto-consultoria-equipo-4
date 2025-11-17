import 'dart:async';
import 'package:location/location.dart';
import 'package:mobile/ports/core/driven/for_managing_location.dart';
import 'package:mobile/domain/core/user_location.dart';

class LocationPackageService implements ForManagingLocation {
  final Location _location = Location();

  @override
  Future<LocationPermissionStatus> requestPermission() async {
    try {
      final permission = await _location.requestPermission();
      return _mapPermissionStatus(permission);
    } catch (e) {
      return LocationPermissionStatus.denied;
    }
  }

  @override
  Future<UserLocation> getCurrentLocation() async {
    try {
      // Verificar que el servicio esté habilitado
      final serviceStatus = await checkServiceStatus();
      if (serviceStatus == LocationServiceStatus.disabled) {
        throw Exception('Servicio de ubicación deshabilitado');
      }

      // Verificar permisos
      final permissionStatus = await checkPermissionStatus();
      if (permissionStatus == LocationPermissionStatus.denied ||
          permissionStatus == LocationPermissionStatus.deniedForever) {
        throw Exception('Permisos de ubicación denegados');
      }

      final locationData = await _location.getLocation();
      return UserLocation(
        latitude: locationData.latitude!,
        longitude: locationData.longitude!,
        accuracy: locationData.accuracy,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<LocationServiceStatus> checkServiceStatus() async {
    try {
      final isEnabled = await _location.serviceEnabled();
      return isEnabled
          ? LocationServiceStatus.enabled
          : LocationServiceStatus.disabled;
    } catch (e) {
      return LocationServiceStatus.disabled;
    }
  }

  @override
  Future<LocationServiceStatus> requestServiceEnable() async {
    try {
      final isEnabled = await _location.requestService();
      return isEnabled
          ? LocationServiceStatus.enabled
          : LocationServiceStatus.disabled;
    } catch (e) {
      return LocationServiceStatus.disabled;
    }
  }

  @override
  Future<LocationPermissionStatus> checkPermissionStatus() async {
    try {
      final permission = await _location.hasPermission();
      return _mapPermissionStatus(permission);
    } catch (e) {
      return LocationPermissionStatus.denied;
    }
  }

  @override
  Future<bool> isLocationAvailable() async {
    try {
      // Verificar servicio
      final serviceStatus = await checkServiceStatus();
      if (serviceStatus == LocationServiceStatus.disabled) {
        final requestResult = await requestServiceEnable();
        if (requestResult == LocationServiceStatus.disabled) {
          return false;
        }
      }

      // Verificar permisos
      final permissionStatus = await checkPermissionStatus();
      if (permissionStatus == LocationPermissionStatus.denied) {
        final requestResult = await requestPermission();
        if (requestResult != LocationPermissionStatus.granted &&
            requestResult != LocationPermissionStatus.whileInUse) {
          return false;
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }


  /// Mapea el estado de permisos del paquete location al enum del dominio
  LocationPermissionStatus _mapPermissionStatus(
    PermissionStatus status,
  ) {
    switch (status) {
      case PermissionStatus.granted:
        return LocationPermissionStatus.granted;
      case PermissionStatus.denied:
        return LocationPermissionStatus.denied;
      case PermissionStatus.deniedForever:
        return LocationPermissionStatus.deniedForever;
      case PermissionStatus.grantedLimited:
        return LocationPermissionStatus.whileInUse;
    }
  }
}

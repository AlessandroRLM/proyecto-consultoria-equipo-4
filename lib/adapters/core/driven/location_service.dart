import 'dart:async';
import 'package:location/location.dart';
import 'package:mobile/domain/core/user_location.dart';
import 'package:mobile/ports/core/driven/for_locating_user.dart';

class LocationService implements ForLocatingUser {
  final Location _location = Location();
  StreamSubscription<LocationData>? _locationSubscription;
  final StreamController<UserLocation> _locationController = StreamController<UserLocation>.broadcast();

  @override
  Stream<UserLocation> get locationStream => _locationController.stream;

  @override
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

  @override
  Future<UserLocation?> getCurrentLocation() async {
    try {
      // Verificar permisos antes de obtener ubicación
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        print('No se tienen los permisos necesarios para obtener ubicación');
        return null;
      }

      // Configurar ajustes de ubicación antes de obtener la posición
      await _location.changeSettings(
        accuracy: LocationAccuracy.high,
        interval: 1000,
        distanceFilter: 0,
      );

      print('Solicitando ubicación...');
      final locationData = await _location.getLocation().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Timeout obteniendo ubicación', const Duration(seconds: 30));
        },
      );

      print('Valor de locationData después de getLocation(): $locationData');
      
      if (locationData.latitude != null && 
          locationData.longitude != null &&
          locationData.latitude != 0.0 && 
          locationData.longitude != 0.0) {
        
        print('Ubicación obtenida: ${locationData.latitude}, ${locationData.longitude}');
        print('Precisión: ${locationData.accuracy}m');
        
        return UserLocation(
          latitude: locationData.latitude!,
          longitude: locationData.longitude!,
          accuracy: locationData.accuracy,
          heading: locationData.heading,
          timestamp: DateTime.now(),
        );
      } else {
        print('Datos de ubicación inválidos: lat=${locationData.latitude}, lng=${locationData.longitude}');
        return null;
      }
    } on TimeoutException catch (e) {
      print('Timeout obteniendo ubicación: $e');
      return null;
    } catch (e) {
      print('Error obteniendo ubicación: $e');
      return null;
    }
  }

  @override
  Future<void> startTracking() async {
    try {
      // Verificar permisos antes de iniciar tracking
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        print('No se pueden iniciar el tracking sin permisos');
        return;
      }

      // Detener tracking anterior si existe
      await stopTracking();

      await _location.changeSettings(
        accuracy: LocationAccuracy.high,
        interval: 5000,
        distanceFilter: 10,
      );

      
      _locationSubscription = _location.onLocationChanged.listen(
        (LocationData locationData) {          
          if (locationData.latitude != null && 
              locationData.longitude != null &&
              locationData.latitude != 0.0 && 
              locationData.longitude != 0.0) {
            
            final userLocation = UserLocation(
              latitude: locationData.latitude!,
              longitude: locationData.longitude!,
              accuracy: locationData.accuracy,
              heading: locationData.heading,
              timestamp: DateTime.now(),
            );
            _locationController.add(userLocation);
          } else {
            print('Datos de ubicación inválidos recibidos en stream');
          }
        },
        onError: (error) {
          print('Error en seguimiento de ubicación: $error');
          _locationController.addError(error);
        },
        onDone: () {
          print('Stream de ubicación finalizado');
        },
      );
    } catch (e) {
      print('Error iniciando tracking: $e');
    }
  }

  @override
  Future<void> stopTracking() async {
    if (_locationSubscription != null) {
      await _locationSubscription?.cancel();
      _locationSubscription = null;
    }
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _locationController.close();
  }
}
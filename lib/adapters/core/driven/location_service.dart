import 'dart:async';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
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
    var status = await Permission.location.status;
    
    if (status.isDenied) {
      status = await Permission.location.request();
    }

    return status.isGranted;
  }

  @override
  Future<UserLocation?> getCurrentLocation() async {
    try {
      final locationData = await _location.getLocation();
      if (locationData.latitude != null && locationData.longitude != null) {
        return UserLocation(
          latitude: locationData.latitude!,
          longitude: locationData.longitude!,
          accuracy: locationData.accuracy,
          heading: locationData.heading,
          timestamp: DateTime.now(),
        );
      }
    } catch (e) {
      print('Error obteniendo ubicación: $e');
    }
    return null;
  }

  @override
  Future<void> startTracking() async {
    await _location.changeSettings(
      accuracy: LocationAccuracy.high,
      interval: 5000,
      distanceFilter: 10,
    );

    _locationSubscription = _location.onLocationChanged.listen(
      (LocationData locationData) {
        if (locationData.latitude != null && locationData.longitude != null) {
          final userLocation = UserLocation(
            latitude: locationData.latitude!,
            longitude: locationData.longitude!,
            accuracy: locationData.accuracy,
            heading: locationData.heading,
            timestamp: DateTime.now(),
          );
          _locationController.add(userLocation);
        }
      },
      onError: (error) {
        print('Error en seguimiento de ubicación: $error');
      },
    );
  }

  @override
  Future<void> stopTracking() async {
    await _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _locationController.close();
  }
}
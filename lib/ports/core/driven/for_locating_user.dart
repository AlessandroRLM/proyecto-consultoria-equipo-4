import 'dart:async';
import 'package:mobile/domain/core/user_location.dart';

abstract class ForLocatingUser {
  Future<bool> requestLocationPermission();
  Future<UserLocation?> getCurrentLocation();
  Stream<UserLocation> get locationStream;
  Future<void> startTracking();
  Future<void> stopTracking();
  void dispose();
}
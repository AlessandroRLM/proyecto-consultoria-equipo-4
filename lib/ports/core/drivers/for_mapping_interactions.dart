import 'package:mobile/domain/core/campus.dart';
import 'package:mobile/domain/core/user_location.dart';

abstract class ForMappingInteractions {
  void onLocationPermissionGranted();
  void onLocationPermissionDenied();
  void onLocationUpdated(UserLocation location);
  void onCampusSelected(Campus campus);
  void onSearchResultsChanged(List<Campus> results);
}
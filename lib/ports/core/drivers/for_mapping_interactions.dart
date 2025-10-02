import 'package:mobile/domain/core/campus.dart';

abstract class ForMappingInteractions {
  void onLocationPermissionDenied();
  void onCampusSelected(Campus campus);
  void onSearchResultsChanged(List<Campus> results);
}
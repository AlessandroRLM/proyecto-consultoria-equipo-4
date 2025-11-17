import 'package:mobile/domain/core/campus.dart';

/// Puerto para manejar interacciones con el mapa.
abstract class ForInteractingMap {
  /// Se ejecuta cuando el usuario deniega los permisos de ubicación.
  void onLocationPermissionDenied();

  /// Se ejecuta cuando el usuario selecciona un campus.
  void onCampusSelected(Campus campus);

  /// Se ejecuta cuando los resultados de búsqueda cambian.
  void onSearchResultsChanged(List<Campus> results);
}
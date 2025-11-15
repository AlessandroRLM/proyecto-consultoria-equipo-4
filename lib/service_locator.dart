import 'package:get_it/get_it.dart';
import 'package:mobile/adapters/auth/driven/services/auth_mock_service.dart';
import 'package:mobile/adapters/core/driven/services/location_package_service.dart';
import 'package:mobile/adapters/core/driven/services/campus_mock_service.dart';
import 'package:mobile/adapters/core/driven/services/mapbox_service.dart';
import 'package:mobile/ports/auth/driven/for_authenticating_user.dart';
import 'package:mobile/ports/core/driven/for_querying_campus.dart';
import 'package:mobile/ports/core/driven/for_managing_map.dart';

final GetIt serviceLocator = GetIt.instance;

void setupServiceLocator() {
  // Servicio de autenticación
  serviceLocator.registerSingleton<ForAuthenticatingUser>(AuthMockService());

  // Servicio para obtener campos clínicos
  serviceLocator.registerLazySingleton<ForQueryingCampus>(
    () => CampusMockService(),
  );

  // Servicio de mapa - depende del servicio de ubicación
  serviceLocator.registerLazySingleton<ForManagingMap>(
    () => MapboxMapService(locationService: LocationPackageService()),
  );
}


/// Método para limpiar servicios que requieren limpieza manual
Future<void> disposeServiceLocator() async {
  // Limpiar servicio de mapa
  if (serviceLocator.isRegistered<ForManagingMap>()) {
    await serviceLocator<ForManagingMap>().dispose();
  }

  // Reset GetIt
  await serviceLocator.reset();
}

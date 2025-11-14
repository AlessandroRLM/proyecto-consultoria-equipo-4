import 'package:get_it/get_it.dart';
import 'package:mobile/adapters/auth/driven/services/shared_preference_auth_data_storage.dart';
import 'package:mobile/adapters/auth/drivers/services/auth_mock_service.dart';
import 'package:mobile/adapters/core/driven/campus_mock_service.dart';
import 'package:mobile/adapters/core/driven/mapbox_service.dart';
import 'package:mobile/ports/auth/drivers/for_authenticating_user.dart';
import 'package:mobile/ports/core/driven/for_querying_campus.dart';

final GetIt serviceLocator = GetIt.instance;

void setupServiceLocator() {
  // servicio de autenticación tipado con el puerto ForAuthenticatingUser y
  // usando SharedPreferenceAuthDataStorage como implementación
  serviceLocator.registerSingleton<ForAuthenticatingUser>(AuthMockService(SharedPreferenceAuthDataStorage()));
  
  // servicio para obtener campos clinicos
  serviceLocator.registerLazySingleton<ForQueryingCampus>(() => CampusMockService());
    
  // servicio para utilizar mapa
  serviceLocator.registerLazySingleton<MapboxService>(() => MapboxService());
}

// Metodo para limpiar servicios que requieren limpieza manual
void disposeServiceLocator() {
  
  if (serviceLocator.isRegistered<MapboxService>()) {
    serviceLocator<MapboxService>().dispose();
  }
  
  // Reset GetIt
  serviceLocator.reset();
}
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/adapters/auth/driven/services/shared_preference_auth_data_storage.dart';
import 'package:mobile/adapters/auth/drivers/services/auth_mock_service.dart';
import 'package:mobile/ports/auth/drivers/for_authenticating_user.dart';
import 'package:mobile/adapters/core/driven/services/location_package_service.dart';
import 'package:mobile/adapters/core/driven/services/campus_mock_service.dart';
import 'package:mobile/adapters/core/driven/services/mapbox_service.dart';
import 'package:mobile/ports/core/driven/for_managing_location.dart';
import 'package:mobile/ports/core/driven/for_querying_campus.dart';
import 'package:mobile/ports/core/driven/for_managing_map.dart';
import 'package:mobile/ports/transport/driven/transport_reservations_management.dart';
import 'package:mobile/adapters/transport/driven/services/transport_mock_service.dart';
import 'package:mobile/adapters/transport/driven/providers/transport_reservations_provider.dart';

final GetIt serviceLocator = GetIt.instance;

void setupServiceLocator(SharedPreferences sharedPreferences) {
  // Registrar SharedPreferences
  serviceLocator.registerSingleton<SharedPreferences>(sharedPreferences);

  // Servicio de autenticación
  serviceLocator.registerSingleton<ForAuthenticatingUser>(AuthMockService(SharedPreferenceAuthDataStorage()));
  
  // Servicio para obtener campos clínicos
  serviceLocator.registerLazySingleton<ForQueryingCampus>(() => CampusMockService());

  // Servicio de ubicación
  serviceLocator.registerLazySingleton<ForManagingLocation>(() => LocationPackageService());

  // Servicio de mapa
  serviceLocator.registerLazySingleton<ForManagingMap>(() => MapboxMapService(locationService: serviceLocator<ForManagingLocation>()));

  // Puerto y adaptador de transporte
  serviceLocator.registerLazySingleton<TransportReservationsManagement>(() => TransportMockService(serviceLocator<SharedPreferences>()));

  // Provider de transporte (depende del puerto)
  serviceLocator.registerLazySingleton<TransportReservationsProvider>(() => TransportReservationsProvider(serviceLocator<TransportReservationsManagement>()));
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


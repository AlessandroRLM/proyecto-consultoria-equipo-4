import 'package:get_it/get_it.dart';
import 'package:mobile/adapters/auth/driven/services/shared_preference_auth_data_storage.dart';
import 'package:mobile/adapters/auth/drivers/services/auth_mock_service.dart';
import 'package:mobile/ports/auth/drivers/for_authenticating_user.dart';
import 'package:mobile/adapters/core/driven/services/location_package_service.dart';
import 'package:mobile/adapters/core/driven/services/campus_mock_service.dart';
import 'package:mobile/adapters/core/driven/services/mapbox_service.dart';
import 'package:mobile/ports/core/driven/for_managing_location.dart';
import 'package:mobile/ports/core/driven/for_querying_campus.dart';
import 'package:mobile/ports/core/driven/for_managing_map.dart';
import 'package:mobile/adapters/transport/driven/local_transport_repository.dart';
import 'package:mobile/adapters/transport/driven/providers/transport_reservations_provider.dart';
import 'package:mobile/ports/transport/driven/for_querying_transport.dart';


final GetIt serviceLocator = GetIt.instance;

void setupServiceLocator() {
  // servicio de autenticación tipado con el puerto ForAuthenticatingUser y
  // usando SharedPreferenceAuthDataStorage como implementación
  serviceLocator.registerSingleton<ForAuthenticatingUser>(AuthMockService(SharedPreferenceAuthDataStorage()));
  
  // servicio para obtener campos clinicos
  serviceLocator.registerLazySingleton<ForQueryingCampus>(() => CampusMockService());

  // Servicio de ubicación
  serviceLocator.registerLazySingleton<ForManagingLocation>(() => LocationPackageService());

  // Servicio de mapa 
  serviceLocator.registerLazySingleton<ForManagingMap>(() => MapboxMapService(locationService: serviceLocator<ForManagingLocation>()));
  
  
// ============================================================
  // TRANSPORTE
  // ============================================================

  // Repositorio local que implementa ForQueryingTransport (driven port)
  serviceLocator.registerLazySingleton<ForQueryingTransport>(
    () => LocalTransportRepository(),
  );

  // Provider principal que conversa directamente con el repositorio
  serviceLocator.registerLazySingleton<TransportReservationsProvider>(
    () => TransportReservationsProvider(
      repo: serviceLocator<ForQueryingTransport>(),
    ),
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


import 'package:get_it/get_it.dart';
import 'package:mobile/adapters/auth/driven/services/shared_preference_auth_data_storage.dart';
import 'package:mobile/adapters/auth/drivers/services/auth_mock_service.dart';
import 'package:mobile/adapters/credentials/driven/credential_request_persistance_mock_service.dart';
import 'package:mobile/adapters/lodging/driven/repositories/lodging_mock_repository.dart';
import 'package:mobile/adapters/lodging/drivers/services/lodging_reserve_service.dart';
import 'package:mobile/ports/auth/drivers/for_authenticating_user.dart';
import 'package:mobile/adapters/core/driven/services/location_package_service.dart';
import 'package:mobile/adapters/core/driven/services/campus_mock_service.dart';
import 'package:mobile/adapters/core/driven/services/mapbox_service.dart';
import 'package:mobile/ports/core/driven/for_managing_location.dart';
import 'package:mobile/ports/core/driven/for_querying_campus.dart';
import 'package:mobile/ports/core/driven/for_managing_map.dart';
import 'package:mobile/adapters/transport/driven/local_transport_repository.dart';
import 'package:mobile/ports/transport/driven/for_querying_transport.dart';
import 'package:mobile/ports/credentials/driven/for_persisting_request.dart';
import 'package:mobile/ports/lodging/driven/for_persisting_reservations.dart';
import 'package:mobile/ports/lodging/driven/for_querying_lodging.dart';
import 'package:mobile/ports/lodging/drivers/for_reserving_lodging.dart';

final GetIt serviceLocator = GetIt.instance;

void setupServiceLocator() {
  // servicio de autenticación tipado con el puerto ForAuthenticatingUser y
  // usando SharedPreferenceAuthDataStorage como implementación
  serviceLocator.registerSingleton<ForAuthenticatingUser>(
    AuthMockService(SharedPreferenceAuthDataStorage())
  );

  // servicio para obtener campos clinicos
  serviceLocator.registerLazySingleton<ForQueryingCampus>(() => CampusMockService());

  // Servicio de ubicación
  serviceLocator.registerLazySingleton<ForManagingLocation>(() => LocationPackageService());

  // TRANSPORTE
  // ============================================================

  // Repositorio local que implementa ForQueryingTransport (driven port)
  serviceLocator.registerLazySingleton<ForQueryingTransport>(
    () => LocalTransportRepository(),
  );
  // ============================================================
  // LODGING
  // ============================================================

  // Servicio de ubicación
  serviceLocator.registerLazySingleton<ForManagingMap>(
    () => MapboxMapService(
      locationService: serviceLocator<ForManagingLocation>()
    )
  );

  //consulta agendas y residencias desde mocks
  // Servicio de credenciales
  serviceLocator.registerLazySingleton<ForPersistingRequest>(
    () => CredentialRequestPersistanceMockService(),
  );

  // Servicio de lodging
  serviceLocator.registerLazySingleton<LodgingMockRepository>(
    () => LodgingMockRepository(),
  );

  // Servicio de consulta de lodging
  serviceLocator.registerLazySingleton<ForQueryingLodging>(
    () => serviceLocator<LodgingMockRepository>(),
  );
  
  // Servicio de persistencia de reservas
  serviceLocator.registerLazySingleton<ForPersistingReservations>(
    () => serviceLocator<LodgingMockRepository>(),
  );

  // Servicio de reserva de lodging
  serviceLocator.registerLazySingleton<ForReservingLodging>(
    () => LodgingReserveService(
      lodgingRepository: serviceLocator<ForPersistingReservations>(),
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
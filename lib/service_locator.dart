import 'package:get_it/get_it.dart';
import 'package:mobile/adapters/auth/driven/services/auth_mock_service.dart';
import 'package:mobile/ports/auth/driven/for_authenticating_user.dart';

final GetIt serviceLocator = GetIt.instance;

void setupServiceLocator() {
  serviceLocator.registerSingleton<ForAuthenticatingUser>(AuthMockService());
}
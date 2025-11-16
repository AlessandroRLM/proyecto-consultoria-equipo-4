import 'package:mobile/domain/models/user/user_model.dart';

/// Puerto para almacenar datos de autenticación.
abstract class ForStoringAuthData {
  /// Almacena los datos de un usuario.
  Future<void> storeUser(UserModel user);
  /// Obtiene los datos de un usuario.
  Future<UserModel?> getStoredUser();

  /// Almacena si el usuario está autenticado.
  Future<void> storeIsAuthenticated(bool isAuthenticated);
  /// Obtiene si el usuario está autenticado.
  Future<bool> getStoredIsAuthenticated();

  /// Limpia los datos de autenticación.
  Future<void> clearAuthData();
}
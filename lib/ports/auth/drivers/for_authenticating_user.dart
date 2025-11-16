import 'package:mobile/domain/models/user/user_model.dart';

/// Puerto para autenticación de usuarios
abstract class ForAuthenticatingUser {
  /// Usuario autenticado (null si no hay sesión)
  UserModel? get currentUser;
  set currentUser(UserModel? value);

  /// Estado de sesión
  bool get isAuthenticated;
  set isAuthenticated(bool value);

  /// Cargas iniciales (tokens, restaurar sesión, etc.)
  Future<void> initialize();

  /// Autentica y deja el usuario en memoria; devuelve true si ok
  Future<bool> login({required String email, required String password});

  /// Inicia flujo de recuperación de contraseña
  Future<void> initRecoverPassword({required String email});

  /// Cierra sesión y limpia estado
  Future<void> logout();
}
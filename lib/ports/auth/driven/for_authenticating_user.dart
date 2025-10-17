import 'package:mobile/domain/models/user/user_model.dart';

abstract class ForAuthenticatingUser {
  /// Usuario autenticado (null si no hay sesión)
  UserModel? get currentUser;

  /// Estado de sesión
  bool get isAuthenticated;

  /// Cargas iniciales (tokens, restaurar sesión, etc.)
  Future<void> initialize();

  /// Autentica y deja el usuario en memoria; devuelve true si ok
  Future<bool> authenticate({required String email, required String password});

  /// Inicia flujo de recuperación de contraseña
  Future<void> initRecoverPassword({required String email});

  /// Cierra sesión y limpia estado
  Future<void> logout();
}
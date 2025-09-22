import 'package:mobile/domain/core/user.dart';

abstract class ForAuthenticatingUser {
  bool get isAuthenticated;
  User? get currentUser;
  
  Future<void> initialize();

  Future<bool> authenticate({
    required String email,
    required String password,
  });

  Future<void> initRecoverPassword({
    required String email,
  });

  Future<void> logout();
}

import 'package:mobile/domain/entities/user.dart';

abstract class ForAuthenticatingUser {
  bool get isAuthenticated;
  
  Future<void> initialize();

  Future<bool> authenticate({
    required String email,
    required String password,
  });

  Future<void> initRecoverPassword({
    required String email,
  });

  Future<void> logout();

  User? get currentUser;
}

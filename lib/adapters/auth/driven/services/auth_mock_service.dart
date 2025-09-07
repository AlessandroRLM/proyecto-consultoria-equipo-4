import 'package:mobile/ports/auth/driven/for_authenticating_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthMockService implements ForAuthenticatingUser {
  static const String _isAuthenticatedKey = 'is_authenticated';

  bool _isAuthenticated = false;
  final String _email = 'test@test.com';
  final String _password = '123456';

  @override
  bool get isAuthenticated => _isAuthenticated;

  @override
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool(_isAuthenticatedKey) ?? false;
    print('Auth state initialized: $_isAuthenticated');
  }

  @override
  Future<bool> authenticate({
    required String email,
    required String password,
  }) async {
    if (email == _email && password == _password) {
      _isAuthenticated = true;
      await _saveToStorage();
      return true;
    }
    _isAuthenticated = false;
    return false;
  }

  @override
  Future<void> initRecoverPassword({required String email}) async {
    if (email == _email) {
      return;
    }
    throw Exception('Email not found');
  }

  @override
  Future<void> logout() async {
    _isAuthenticated = false;
    await _clearStorage();
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isAuthenticatedKey, _isAuthenticated);
  }

  Future<void> _clearStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isAuthenticatedKey);
  }
}

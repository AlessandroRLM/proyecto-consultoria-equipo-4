import 'package:mobile/adapters/auth/driven/services/user_mock_service.dart';
import 'package:mobile/domain/entities/user.dart';
import 'package:mobile/ports/auth/driven/for_authenticating_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthMockService implements ForAuthenticatingUser {
  static const String _isAuthenticatedKey = 'is_authenticated';
  final UserMockService _userService = UserMockService();

  bool _isAuthenticated = false;
  User? _currentUser;

  @override
  bool get isAuthenticated => _isAuthenticated;
  @override
  User? get currentUser => _currentUser;

  @override
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool(_isAuthenticatedKey) ?? false;
  }

  @override
  Future<bool> authenticate({
    required String email,
    required String password,
  }) async {
    final user = _userService.login(email, password);
    if (user != null && user.email == email && user.password == password) {
      _isAuthenticated = true;
      _currentUser = user;
      await _saveToStorage();
      return true;
    }
    _isAuthenticated = false;
    _currentUser = null;
    return false;
  }

  @override
  Future<void> initRecoverPassword({required String email}) async {
    final user = _userService.getUserByEmail(email);
    if (user!=null) {
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

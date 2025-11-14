import 'package:mobile/domain/models/user/user_model.dart';
import 'package:mobile/ports/auth/driven/for_storing_auth_data.dart';
import 'package:mobile/ports/auth/drivers/for_authenticating_user.dart';

class AuthMockService implements ForAuthenticatingUser {
  final ForStoringAuthData _authDataRepository;

  AuthMockService(this._authDataRepository);

  // Lista inmutable para un mock más seguro.
  static const List<UserModel> _users = [
    UserModel(
      id: 'u001',
      email: 'test@test.com',
      password: '123456',
      name: 'Juan Perez',
      rut: '12.345.678-9',
      aCarrera: 3,
      sede: 'Santiago',
      servicesId: 3,
    ),
    UserModel(
      id: 'u002',
      email: 'user1@user1.com',
      password: '123456',
      name: 'Benjamín Soto',
      rut: '11.111.111-1',
      aCarrera: 2,
      sede: 'Temuco',
      servicesId: 0,
    ),
    UserModel(
      id: 'u003',
      email: 'user2@user2.com',
      password: '123456',
      name: 'Carla Méndez',
      rut: '22.222.222-2',
      aCarrera: 4,
      sede: 'El Llano',
      servicesId: 1,
    ),
    UserModel(
      id: 'u004',
      email: 'user3@user3.com',
      password: '123456',
      name: 'Diego Rivas',
      rut: '33.333.333-3',
      aCarrera: 1,
      sede: 'Providencia',
      servicesId: 4,
    ),
  ];

  /// Devuelve el usuario si coincide email+password; null si no hay match.
  UserModel? _authenticate(String email, String password) {
    for (final u in _users) {
      if (u.email == email && u.password == password) return u;
    }
    return null;
  }

  /// Busca por email exacto; null si no existe.
  UserModel? _getUserByEmail(String email) {
    for (final u in _users) {
      if (u.email == email) return u;
    }
    return null;
  }

  bool _isAuthenticated = false;
  UserModel? _currentUser;

  @override
  bool get isAuthenticated => _isAuthenticated;

  @override
  set isAuthenticated(bool value) {
    _isAuthenticated = value;
    _authDataRepository.storeIsAuthenticated(value);
  }

  @override
  UserModel? get currentUser => _currentUser;
  @override
  set currentUser(UserModel? value) {
    _currentUser = value;
    _authDataRepository.storeUser(value!);
  }

  @override
  Future<void> initialize() async {
    _isAuthenticated = await _authDataRepository.getStoredIsAuthenticated();
    _currentUser = await _authDataRepository.getStoredUser();
  }

  @override
  Future<bool> login({required String email, required String password}) async {
    final user = _authenticate(email, password);
    if (user != null && user.email == email && user.password == password) {
      currentUser = user;
      isAuthenticated = true;
      return true;
    }
    isAuthenticated = false;
    currentUser = null;
    return false;
  }

  @override
  Future<void> initRecoverPassword({required String email}) async {
    final user = _getUserByEmail(email);
    if (user != null) {
      return;
    }
    throw Exception('Email not found');
  }

  @override
  Future<void> logout() async {
    _isAuthenticated = false;
    await _authDataRepository.clearAuthData();
  }
}

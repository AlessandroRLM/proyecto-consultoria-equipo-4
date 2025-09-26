import 'package:mobile/domain/models/user/user_model.dart';

class UserMockService {
  const UserMockService();

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
      servicesId: 'svc001',
    ),
    UserModel(
      id: 'u002',
      email: 'user1@user1.com',
      password: '123456',
      name: 'Benjamín Soto',
      rut: '11.111.111-1',
      aCarrera: 2,
      sede: 'Temuco',
      servicesId: 'svc002',
    ),
    UserModel(
      id: 'u003',
      email: 'user3@user2.com',
      password: '123456',
      name: 'Carla Méndez',
      rut: '22.222.222-2',
      aCarrera: 4,
      sede: 'El Llano',
      servicesId: 'svc003',
    ),
    UserModel(
      id: 'u004',
      email: 'user3@user3.com',
      password: '123456',
      name: 'Diego Rivas',
      rut: '33.333.333-3',
      aCarrera: 1,
      sede: 'Providencia',
      servicesId: 'svc004',
    ),
  ];

  /// Devuelve el usuario si coincide email+password; null si no hay match.
  UserModel? login(String email, String password) {
    for (final u in _users) {
      if (u.email == email && u.password == password) return u;
    }
    return null;
  }

  /// Busca por email exacto; null si no existe.
  UserModel? getUserByEmail(String email) {
    for (final u in _users) {
      if (u.email == email) return u;
    }
    return null;
  }

  /// Útil para tests o listados.
  List<UserModel> all() => _users;
}

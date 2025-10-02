import 'package:mobile/domain/core/user.dart';

class UserMockService {
  final List<User> _users = [
    User(
      id: 'u001',
      email: 'test@test.com',
      password: '123456',
      name: 'Juan Perez',
      rut: '12.345.678-9',
      aCarrera: 3,
      sede: 'Santiago',
      servicesId: 3,
    ),
    User(
      id: 'u002',
      email: 'user1@user1.com',
      password: '123456',
      name: 'Benjamín Soto',
      rut: '11.1111.111-1',
      aCarrera: 2,
      sede: 'Temuco',
      servicesId: 0,
    ),
    User(
      id: 'u003',
      email: 'user2@user2.com',
      password: '123456',
      name: 'Carla Méndez',
      rut: '22.222.222-2',
      aCarrera: 4,
      sede: 'El Llano',
      servicesId: 1,
    ),
    User(
      id: 'u004',
      email: 'user3@user3.com',
      password: '123456',
      name: 'Diego Rivas',
      rut: '33.333.333-3',
      aCarrera: 1,
      sede: 'Provicencia',
      servicesId: 2
    ),
  ];

  User? login(String email, String password) {
    return _users.firstWhere(
      (user) => user.email == email && user.password == password,
    );
  }

  User? getUserByEmail(String email) {
    return _users.firstWhere(
      (user) => user.email == email,
    );
  }

}
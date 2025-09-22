class User {
  final String id;
  final String email;
  final String password;
  final String name;
  final String rut;
  final int aCarrera;
  final String sede;
  final int servicesId;     // Si es 0 acceso a credenciales, 1 acceso a transporte, 2 acceso a alojamiento y 3 a ambos
  final String? avatarUrl;

  User({
    required this.id,
    required this.email,
    required this.password,
    required this.name,
    required this.rut,
    required this.aCarrera,
    required this.sede,
    required this.servicesId,
    this.avatarUrl,
  });
}
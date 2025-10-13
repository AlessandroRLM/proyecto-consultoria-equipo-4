import 'dart:convert';

class UserModel {
  final String id;
  final String email;

  /// Si solo la usas para login, considera limpiar este campo tras autenticar.
  final String password;
  final String name;
  final String rut;
  final int aCarrera;
  final String sede;
  final int servicesId;
  final String? avatarUrl;

  const UserModel({
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

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: (json['id'] ?? json['user_id']).toString(),
    email: json['email'] as String,
    password: (json['password'] ?? '') as String,
    name: json['name'] as String,
    rut: json['rut'] as String,
    aCarrera: (json['a_carrera'] ?? json['aCarrera']) as int,
    sede: json['sede'] as String,
    servicesId: (json['services_id'] ?? json['servicesId']) as int,
    avatarUrl: (json['avatar_url'] ?? json['avatarUrl']) as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'password': password,
    'name': name,
    'rut': rut,
    'a_carrera': aCarrera,
    'sede': sede,
    'services_id': servicesId,
    'avatar_url': avatarUrl,
  };

  static UserModel fromJsonString(String s) =>
      UserModel.fromJson(jsonDecode(s) as Map<String, dynamic>);
  String toJsonString() => jsonEncode(toJson());
}

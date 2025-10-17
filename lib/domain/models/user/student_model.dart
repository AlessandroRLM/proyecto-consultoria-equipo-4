import 'dart:convert';

class StudentModel {
  final int id;
  final String rut; // puede ser pasaporte; no validar formato
  final String name;
  final String lastName;
  final String condition; // p.ej. "Interno"
  final String profession; // p.ej. "Medicina"
  final String mobile; // si no hay, viene "No"
  final String state; // p.ej. "Activo"
  final int sedeId;
  final int userId;
  final int groupId; // según backend, “siempre 6/7” en ejemplos
  final String acceptRul; // "Sí"/"No"

  const StudentModel({
    required this.id,
    required this.rut,
    required this.name,
    required this.lastName,
    required this.condition,
    required this.profession,
    required this.mobile,
    required this.state,
    required this.sedeId,
    required this.userId,
    required this.groupId,
    required this.acceptRul,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) => StudentModel(
    id: json['id'] as int,
    rut: json['rut'] as String,
    name: json['name'] as String,
    lastName: json['last_name'] as String,
    condition: json['condition'] as String,
    profession: json['profession'] as String,
    mobile: json['mobile'] as String,
    state: json['state'] as String,
    sedeId: json['sede_id'] as int,
    userId: json['user_id'] as int,
    groupId: json['group_id'] as int,
    acceptRul: json['accept_rul'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'rut': rut,
    'name': name,
    'last_name': lastName,
    'condition': condition,
    'profession': profession,
    'mobile': mobile,
    'state': state,
    'sede_id': sedeId,
    'user_id': userId,
    'group_id': groupId,
    'accept_rul': acceptRul,
  };

  static StudentModel fromJsonString(String s) =>
      StudentModel.fromJson(jsonDecode(s) as Map<String, dynamic>);
  String toJsonString() => jsonEncode(toJson());
}

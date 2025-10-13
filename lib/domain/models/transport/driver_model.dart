import 'dart:convert';

class DriverModel {
  final String name;
  final String license;
  final String contact;

  const DriverModel({
    required this.name,
    required this.license,
    required this.contact,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) => DriverModel(
    name: json['name'] as String,
    license: json['license'] as String,
    contact: json['contact'] as String,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'license': license,
    'contact': contact,
  };

  static DriverModel? tryFromJson(Map<String, dynamic>? json) =>
      json == null ? null : DriverModel.fromJson(json);

  static DriverModel fromJsonString(String s) =>
      DriverModel.fromJson(jsonDecode(s) as Map<String, dynamic>);
  String toJsonString() => jsonEncode(toJson());
}

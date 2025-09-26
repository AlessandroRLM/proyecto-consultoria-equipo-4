import 'dart:convert';

/// campo clínico (id, nombre, comuna/ciudad, lat/lon)
class ClinicalFieldModel {
  final int id;
  final String name;
  final String city;
  final String commune;
  final double latitude;
  final double longitude;

  const ClinicalFieldModel({
    required this.id,
    required this.name,
    required this.city,
    required this.commune,
    required this.latitude,
    required this.longitude,
  });

  factory ClinicalFieldModel.fromJson(Map<String, dynamic> json) =>
      ClinicalFieldModel(
        id: json['id'] as int,
        name: json['name'] as String,
        city: json['city'] as String,
        commune: json['commune'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'city': city,
    'commune': commune,
    'latitude': latitude,
    'longitude': longitude,
  };

  static List<ClinicalFieldModel> listFromJsonList(List<dynamic> list) => list
      .map((e) => ClinicalFieldModel.fromJson(e as Map<String, dynamic>))
      .toList();

  static List<ClinicalFieldModel> listFromJsonString(String s) =>
      listFromJsonList(jsonDecode(s) as List<dynamic>);
}

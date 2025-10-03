import 'dart:convert';

class CampusModel {
  final int id;
  final String name;
  final String city;
  final String commune;
  final double latitude;
  final double longitude;

  const CampusModel({
    required this.id,
    required this.name,
    required this.city,
    required this.commune,
    required this.latitude,
    required this.longitude,
  });

  factory CampusModel.fromJson(Map<String, dynamic> json) => CampusModel(
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

  static CampusModel fromJsonString(String s) =>
      CampusModel.fromJson(jsonDecode(s) as Map<String, dynamic>);
  String toJsonString() => jsonEncode(toJson());
}

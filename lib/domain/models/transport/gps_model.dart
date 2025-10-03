import 'dart:convert';

class GpsPositionModel {
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  const GpsPositionModel({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  factory GpsPositionModel.fromJson(Map<String, dynamic> json) =>
      GpsPositionModel(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        timestamp: DateTime.parse(json['timestamp'] as String),
      );

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'timestamp': timestamp.toIso8601String(),
  };

  static GpsPositionModel? tryFromJson(Map<String, dynamic>? json) =>
      json == null ? null : GpsPositionModel.fromJson(json);

  static GpsPositionModel fromJsonString(String s) =>
      GpsPositionModel.fromJson(jsonDecode(s) as Map<String, dynamic>);
  String toJsonString() => jsonEncode(toJson());
}

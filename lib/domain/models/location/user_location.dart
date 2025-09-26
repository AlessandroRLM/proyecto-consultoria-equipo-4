import 'dart:convert';

class UserLocationModel {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? heading;
  final DateTime timestamp;

  const UserLocationModel({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.heading,
    required this.timestamp,
  });

  factory UserLocationModel.fromJson(Map<String, dynamic> json) =>
      UserLocationModel(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        accuracy: (json['accuracy'] as num?)?.toDouble(),
        heading: (json['heading'] as num?)?.toDouble(),
        timestamp: DateTime.parse(json['timestamp'] as String),
      );

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    if (accuracy != null) 'accuracy': accuracy,
    if (heading != null) 'heading': heading,
    'timestamp': timestamp.toIso8601String(),
  };

  static UserLocationModel fromJsonString(String s) =>
      UserLocationModel.fromJson(jsonDecode(s) as Map<String, dynamic>);
  String toJsonString() => jsonEncode(toJson());

  // === Igualdad como en tu clase original ===
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserLocationModel &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;

  @override
  String toString() =>
      'UserLocationModel(lat: $latitude, lon: $longitude, acc: $accuracy, head: $heading, ts: $timestamp)';
}

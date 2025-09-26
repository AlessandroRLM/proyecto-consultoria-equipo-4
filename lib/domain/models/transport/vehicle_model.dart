import 'dart:convert';

class VehicleModel {
  final String plate;
  final String model;
  final String type;

  const VehicleModel({
    required this.plate,
    required this.model,
    required this.type,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) => VehicleModel(
    plate: json['plate'] as String,
    model: json['model'] as String,
    type: json['type'] as String,
  );

  Map<String, dynamic> toJson() => {
    'plate': plate,
    'model': model,
    'type': type,
  };

  static VehicleModel fromJsonString(String s) =>
      VehicleModel.fromJson(jsonDecode(s) as Map<String, dynamic>);
  String toJsonString() => jsonEncode(toJson());
}

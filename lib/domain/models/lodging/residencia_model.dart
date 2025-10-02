import 'campo_clinico_model.dart';
import 'imagen_model.dart';

class ResidenciaModel {
  final int homeId;
  final String residenceName;
  final String residenceManager;
  final String address;
  final double latitude;
  final double longitude;
  final int bedCount;
  final List<String> availableServices;
  final List<ImagenResidencia> images;
  final List<CampoClinico> clinicalFields;

  const ResidenciaModel({
    required this.homeId,
    required this.residenceName,
    required this.residenceManager,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.bedCount,
    required this.availableServices,
    required this.images,
    required this.clinicalFields,
  });

  factory ResidenciaModel.fromJson(Map<String, dynamic> json) =>
      ResidenciaModel(
        homeId: _toInt(json['homeId']),
        residenceName: (json['residenceName'] ?? '').toString(),
        residenceManager: (json['residenceManager'] ?? '').toString(),
        address: (json['address'] ?? '').toString(),
        latitude: _toDouble(json['latitude']),
        longitude: _toDouble(json['longitude']),
        bedCount: _toInt(json['bedCount']),
        availableServices:
            (json['availableServices'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const <String>[],
        images:
            (json['images'] as List<dynamic>?)
                ?.map(
                  (e) => ImagenResidencia.fromJson(e as Map<String, dynamic>),
                )
                .toList() ??
            const <ImagenResidencia>[],
        clinicalFields:
            (json['clinicalFields'] as List<dynamic>?)
                ?.map((e) => CampoClinico.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const <CampoClinico>[],
      );

  // ---- helpers privados ----
  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim()) ?? 0;
    return 0;
  }

  static double _toDouble(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.trim()) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() => {
    'homeId': homeId,
    'residenceName': residenceName,
    'residenceManager': residenceManager,
    'address': address,
    'latitude': latitude,
    'longitude': longitude,
    'bedCount': bedCount,
    'availableServices': availableServices,
    'images': images.map((e) => e.toJson()).toList(),
    'clinicalFields': clinicalFields.map((e) => e.toJson()).toList(),
  };
}

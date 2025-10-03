import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/domain/models/transport/gps_model.dart';
import 'dart:convert';

void main() {
  group('GpsPositionModel', () {
    final jsonMap = {
      "latitude": 12.3456,
      "longitude": -76.5432,
      "timestamp": "2025-09-29T12:34:56.000Z",
    };

    test('fromJson crea GpsPositionModel correctamente', () {
      final gps = GpsPositionModel.fromJson(jsonMap);

      expect(gps.latitude, 12.3456);
      expect(gps.longitude, -76.5432);
      expect(gps.timestamp.toUtc(), DateTime.parse("2025-09-29T12:34:56.000Z"));
    });

    test('toJson devuelve el mismo mapa (timestamp en ISO 8601)', () {
      final gps = GpsPositionModel.fromJson(jsonMap);
      final toJson = gps.toJson();

      expect(toJson['latitude'], 12.3456);
      expect(toJson['longitude'], -76.5432);
      expect(toJson['timestamp'], "2025-09-29T12:34:56.000Z");
    });

    test('fromJsonString y toJsonString funcionan correctamente', () {
      final jsonString = jsonEncode(jsonMap);
      final gps = GpsPositionModel.fromJsonString(jsonString);

      expect(gps.latitude, 12.3456);
      expect(gps.longitude, -76.5432);

      final backToString = gps.toJsonString();
      final decoded = jsonDecode(backToString) as Map<String, dynamic>;
      expect(decoded, jsonMap);
    });

    test('tryFromJson devuelve null si recibe null', () {
      final gps = GpsPositionModel.tryFromJson(null);
      expect(gps, null);
    });

    test('tryFromJson devuelve objeto si recibe JSON válido', () {
      final gps = GpsPositionModel.tryFromJson(jsonMap);
      expect(gps, isA<GpsPositionModel>());
      expect(gps!.latitude, 12.3456);
    });

    test('lanza TypeError si falta clave latitude', () {
      final incomplete = {...jsonMap}..remove('latitude');
      expect(() => GpsPositionModel.fromJson(incomplete), throwsA(isA<TypeError>()));
    });

    test('lanza TypeError si tipo incorrecto', () {
      final wrongType = {...jsonMap, 'longitude': 'no es un double'};
      expect(() => GpsPositionModel.fromJson(wrongType), throwsA(isA<TypeError>()));
    });
  });
}
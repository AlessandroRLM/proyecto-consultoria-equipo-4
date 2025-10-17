import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/domain/models/location/user_location.dart';
import 'dart:convert';

void main() {
  group('UserLocationModel', () {
    final jsonMap = {
      "latitude": -33.4475,
      "longitude": -70.6736,
      "accuracy": 5.5,
      "heading": 90.0,
      "timestamp": "2025-09-29T12:34:56.000Z"
    };

    final jsonString = jsonEncode(jsonMap);

    test('fromJson crea correctamente el objeto', () {
      final model = UserLocationModel.fromJson(jsonMap);

      expect(model.latitude, -33.4475);
      expect(model.longitude, -70.6736);
      expect(model.accuracy, 5.5);
      expect(model.heading, 90.0);
      expect(model.timestamp, DateTime.parse("2025-09-29T12:34:56.000Z"));
    });

    test('toJson produce el mapa correcto', () {
      final model = UserLocationModel.fromJson(jsonMap);
      final map = model.toJson();

      expect(map['latitude'], jsonMap['latitude']);
      expect(map['longitude'], jsonMap['longitude']);
      expect(map['accuracy'], jsonMap['accuracy']);
      expect(map['heading'], jsonMap['heading']);
      expect(map['timestamp'], jsonMap['timestamp']);
    });

    test('fromJsonString parsea correctamente el JSON', () {
      final model = UserLocationModel.fromJsonString(jsonString);
      expect(model.latitude, -33.4475);
      expect(model.longitude, -70.6736);
    });

    test('toJsonString serializa correctamente el objeto', () {
      final model = UserLocationModel.fromJson(jsonMap);
      final s = model.toJsonString();
      final decoded = jsonDecode(s);

      expect(decoded['latitude'], jsonMap['latitude']);
      expect(decoded['longitude'], jsonMap['longitude']);
    });

    test('igualdad funciona correctamente basado en latitud y longitud', () {
      final a = UserLocationModel.fromJson(jsonMap);
      final b = UserLocationModel.fromJson(jsonMap);

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('maneja campos opcionales nulos correctamente', () {
      final minimalJson = {
        "latitude": -33.44,
        "longitude": -70.67,
        "timestamp": "2025-09-29T12:34:56.000Z"
      };
      final model = UserLocationModel.fromJson(minimalJson);

      expect(model.accuracy, null);
      expect(model.heading, null);
      expect(model.latitude, -33.44);
    });
  });
}

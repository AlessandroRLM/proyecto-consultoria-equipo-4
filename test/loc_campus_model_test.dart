import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/domain/models/location/campus_model.dart';
import 'dart:convert';

void main() {
  group('CampusModel', () {
    final jsonMap = {
      "id": 201,
      "name": "Providencia",
      "city": "Santiago",
      "commune": "Providencia",
      "latitude": -33.42,
      "longitude": -70.62,
    };

    final jsonString = jsonEncode(jsonMap);

    test('fromJson crea correctamente el objeto', () {
      final model = CampusModel.fromJson(jsonMap);

      expect(model.id, 201);
      expect(model.name, "Providencia");
      expect(model.city, "Santiago");
      expect(model.commune, "Providencia");
      expect(model.latitude, -33.42);
      expect(model.longitude, -70.62);
    });

    test('toJson produce el mapa correcto', () {
      final model = CampusModel.fromJson(jsonMap);
      final map = model.toJson();

      expect(map['id'], jsonMap['id']);
      expect(map['name'], jsonMap['name']);
      expect(map['city'], jsonMap['city']);
      expect(map['commune'], jsonMap['commune']);
      expect(map['latitude'], jsonMap['latitude']);
      expect(map['longitude'], jsonMap['longitude']);
    });

    test('fromJsonString crea correctamente el objeto desde string', () {
      final model = CampusModel.fromJsonString(jsonString);

      expect(model.id, 201);
      expect(model.name, "Providencia");
      expect(model.city, "Santiago");
      expect(model.commune, "Providencia");
      expect(model.latitude, -33.42);
      expect(model.longitude, -70.62);
    });

    test('toJsonString produce el string correcto', () {
      final model = CampusModel.fromJson(jsonMap);
      final s = model.toJsonString();
      final decoded = jsonDecode(s) as Map<String, dynamic>;

      expect(decoded['id'], 201);
      expect(decoded['name'], "Providencia");
      expect(decoded['city'], "Santiago");
      expect(decoded['commune'], "Providencia");
      expect(decoded['latitude'], -33.42);
      expect(decoded['longitude'], -70.62);
    });
  });
}

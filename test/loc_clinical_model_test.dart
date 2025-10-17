import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/domain/models/location/clinical_model.dart';
import 'dart:convert';

void main() {
  group('ClinicalFieldModel', () {
    final jsonMap = {
      "id": 101,
      "name": "Providencia Healthcare Center",
      "city": "Santiago",
      "commune": "Providencia",
      "latitude": -33.42,
      "longitude": -70.62,
    };

    final jsonString = jsonEncode([jsonMap]); // para listFromJsonString

    test('fromJson crea correctamente el objeto', () {
      final model = ClinicalFieldModel.fromJson(jsonMap);

      expect(model.id, 101);
      expect(model.name, "Providencia Healthcare Center");
      expect(model.city, "Santiago");
      expect(model.commune, "Providencia");
      expect(model.latitude, -33.42);
      expect(model.longitude, -70.62);
    });

    test('toJson produce el mapa correcto', () {
      final model = ClinicalFieldModel.fromJson(jsonMap);
      final map = model.toJson();

      expect(map['id'], jsonMap['id']);
      expect(map['name'], jsonMap['name']);
      expect(map['city'], jsonMap['city']);
      expect(map['commune'], jsonMap['commune']);
      expect(map['latitude'], jsonMap['latitude']);
      expect(map['longitude'], jsonMap['longitude']);
    });

    test('listFromJsonList parsea correctamente una lista', () {
      final list = [jsonMap, jsonMap];
      final models = ClinicalFieldModel.listFromJsonList(list);

      expect(models.length, 2);
      expect(models[0].id, 101);
      expect(models[1].id, 101);
    });

    test('listFromJsonString parsea correctamente un JSON string', () {
      final models = ClinicalFieldModel.listFromJsonString(jsonString);

      expect(models.length, 1);
      expect(models[0].name, "Providencia Healthcare Center");
    });
  });
}

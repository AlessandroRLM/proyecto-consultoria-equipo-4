import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import 'package:mobile/domain/models/transport/vehicle_model.dart';

void main() {
  group('VehicleModel', () {
    final jsonMap = {
      "plate": "ABC123",
      "model": "Toyota Corolla",
      "type": "Sedán",
    };

    test('fromJson crea un VehicleModel correctamente', () {
      final vehicle = VehicleModel.fromJson(jsonMap);

      expect(vehicle.plate, "ABC123");
      expect(vehicle.model, "Toyota Corolla");
      expect(vehicle.type, "Sedán");
    });

    test('toJson devuelve el mismo mapa', () {
      final vehicle = VehicleModel.fromJson(jsonMap);
      expect(vehicle.toJson(), jsonMap);
    });

    test('fromJsonString y toJsonString funcionan correctamente', () {
      final jsonString = jsonEncode(jsonMap);
      final vehicle = VehicleModel.fromJsonString(jsonString);

      expect(vehicle.plate, "ABC123");
      expect(vehicle.model, "Toyota Corolla");
      expect(vehicle.type, "Sedán");

      final backToString = vehicle.toJsonString();
      final decoded = jsonDecode(backToString) as Map<String, dynamic>;
      expect(decoded, jsonMap);
    });

    test('lanza excepción si falta la clave plate', () {
      final incomplete = {...jsonMap}..remove('plate');

      expect(
        () => VehicleModel.fromJson(incomplete),
        throwsA(isA<TypeError>()),
      );
    });

    test('lanza excepción si falta la clave model', () {
      final incomplete = {...jsonMap}..remove('model');

      expect(
        () => VehicleModel.fromJson(incomplete),
        throwsA(isA<TypeError>()),
      );
    });

    test('lanza excepción si falta la clave type', () {
      final incomplete = {...jsonMap}..remove('type');

      expect(
        () => VehicleModel.fromJson(incomplete),
        throwsA(isA<TypeError>()),
      );
    });

    test('lanza excepción si un campo tiene tipo incorrecto', () {
      final wrongType = {...jsonMap, 'plate': 123}; // debería ser String

      expect(
        () => VehicleModel.fromJson(wrongType),
        throwsA(isA<TypeError>()),
      );
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/domain/models/transport/driver_model.dart';
import 'dart:convert';

void main() {
  group('DriverModel', () {
    final jsonMap = {
      "name": "Juan Pérez",
      "license": "ABC12345",
      "contact": "+56987654321",
    };

    test('fromJson crea DriverModel correctamente', () {
      final driver = DriverModel.fromJson(jsonMap);

      expect(driver.name, "Juan Pérez");
      expect(driver.license, "ABC12345");
      expect(driver.contact, "+56987654321");
    });

    test('toJson devuelve el mismo mapa', () {
      final driver = DriverModel.fromJson(jsonMap);
      final toJson = driver.toJson();

      expect(toJson, jsonMap);
    });

    test('fromJsonString y toJsonString funcionan correctamente', () {
      final jsonString = jsonEncode(jsonMap);
      final driver = DriverModel.fromJsonString(jsonString);

      expect(driver.name, "Juan Pérez");
      expect(driver.license, "ABC12345");

      final backToString = driver.toJsonString();
      final decoded = jsonDecode(backToString) as Map<String, dynamic>;
      expect(decoded, jsonMap);
    });

    test('tryFromJson devuelve null si recibe null', () {
      final driver = DriverModel.tryFromJson(null);
      expect(driver, null);
    });

    test('tryFromJson devuelve objeto si recibe JSON válido', () {
      final driver = DriverModel.tryFromJson(jsonMap);
      expect(driver, isA<DriverModel>());
      expect(driver!.name, "Juan Pérez");
    });

    test('lanza TypeError si falta la clave name', () {
      final incomplete = {...jsonMap}..remove('name');
      expect(() => DriverModel.fromJson(incomplete), throwsA(isA<TypeError>()));
    });

    test('lanza TypeError si tipo incorrecto', () {
      final wrongType = {...jsonMap, 'license': 12345}; // debería ser String
      expect(() => DriverModel.fromJson(wrongType), throwsA(isA<TypeError>()));
    });
  });
}

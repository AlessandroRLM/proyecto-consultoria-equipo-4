import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/domain/models/lodging/imagen_model.dart';
import 'dart:convert';

void main() {
  group('ImagenResidencia', () {
    final jsonWithDesc = {
      "url": "https://example.com/image.jpg",
      "description": "Frente de la residencia"
    };
    // se crea una residencia con descripción 

    final jsonWithoutDesc = {
      "url": "https://example.com/image2.jpg",
    };
    // residencia sin descripción

    test('fromJson residencia con descripción', () {
      final img = ImagenResidencia.fromJson(jsonWithDesc);
      expect(img.url, "https://example.com/image.jpg");
      expect(img.descripcion, "Frente de la residencia");
    });


    test('fromJson residencia sin descripción', () {
      final img = ImagenResidencia.fromJson(jsonWithoutDesc);
      expect(img.url, "https://example.com/image2.jpg");
      expect(img.descripcion, null);
    });

    test('toJson incluye description si existe', () {
      final img = ImagenResidencia.fromJson(jsonWithDesc);
      final toJson = img.toJson();
      expect(toJson['url'], "https://example.com/image.jpg");
      expect(toJson['description'], "Frente de la residencia");
    });

    test('toJson no incluye description si es null', () {
      final img = ImagenResidencia.fromJson(jsonWithoutDesc);
      final toJson = img.toJson();
      expect(toJson['url'], "https://example.com/image2.jpg");
      expect(toJson.containsKey('description'), false);
    });

    test('fromJson lanza TypeError si falta url', () {
      final incomplete = {"description": "Algo"};
      expect(() => ImagenResidencia.fromJson(incomplete), throwsA(isA<TypeError>()));
    });

    test('fromJson lanza TypeError si url no es String', () {
      final wrongType = {"url": 123, "description": "Algo"};
      expect(() => ImagenResidencia.fromJson(wrongType), throwsA(isA<TypeError>()));
    });

    test('fromJsonString y toJsonString funcionan correctamente', () {
      final jsonString = jsonEncode(jsonWithDesc);
      final img = ImagenResidencia.fromJson(jsonDecode(jsonString));
      final backToString = jsonEncode(img.toJson());
      expect(backToString, jsonString);
    });
  });
}

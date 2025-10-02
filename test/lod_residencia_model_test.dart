import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/domain/models/lodging/residencia_model.dart';
import 'dart:convert';

void main() {
  group('ResidenciaModel', () {
    final sampleJson = {
      "homeId": 101,
      "residenceName": "Los Cipreses Residence",
      "residenceManager": "Beatriz Salazar",
      "address": "1234 Evergreen Avenue, Santiago, Chile",
      "latitude": -33.4475,
      "longitude": -70.6736,
      "bedCount": 20,
      "availableServices": [
        "television",
        "wifi",
        "hot water",
        "heating",
        "laundry",
        "dining room"
      ],
      "images": [
        {
          "url": "https://example.com/img1.jpg",
          "description": "Exterior view of the residence"
        },
        {
          "url": "https://example.com/img2.jpg",
          "description": "Community room"
        },
        {
          "url": "https://example.com/img3.jpg",
          "description": "Double bedroom"
        }
      ],
      "clinicalFields": [
        {
          "clinicalFieldId": 1,
          "clinicalFieldName": "Providencia Healthcare Center"
        },
        {
          "clinicalFieldId": 2,
          "clinicalFieldName": "Santa María Hospital"
        }
      ]
    };

    test('fromJson funciona correctamente', () {
      final res = ResidenciaModel.fromJson(sampleJson);

      expect(res.homeId, 101);
      expect(res.residenceName, "Los Cipreses Residence");
      expect(res.residenceManager, "Beatriz Salazar");
      expect(res.address, "1234 Evergreen Avenue, Santiago, Chile");
      expect(res.latitude, closeTo(-33.4475, 0.0001));
      expect(res.longitude, closeTo(-70.6736, 0.0001));
      expect(res.bedCount, 20);

      expect(res.availableServices, [
        "television",
        "wifi",
        "hot water",
        "heating",
        "laundry",
        "dining room"
      ]);

      // Verificar imágenes
      expect(res.images.length, 3);
      expect(res.images[0].url, "https://example.com/img1.jpg");
      expect(res.images[0].descripcion, "Exterior view of the residence");
      expect(res.images[1].url, "https://example.com/img2.jpg");
      expect(res.images[1].descripcion, "Community room");
      expect(res.images[2].url, "https://example.com/img3.jpg");
      expect(res.images[2].descripcion, "Double bedroom");

      // Verificar campos clínicos
      expect(res.clinicalFields.length, 2);
      expect(res.clinicalFields[0].clinicalFieldId, 1);
      expect(res.clinicalFields[0].clinicalFieldName, "Providencia Healthcare Center");
      expect(res.clinicalFields[1].clinicalFieldId, 2);
      expect(res.clinicalFields[1].clinicalFieldName, "Santa María Hospital");
    });

    test('toJson respeta estructura y tipos', () {
      final res = ResidenciaModel.fromJson(sampleJson);
      final map = res.toJson();

      expect(map['homeId'], 101);
      expect(map['residenceName'], "Los Cipreses Residence");
      expect(map['availableServices'].length, 6);
      expect(map['images'][0]['url'], "https://example.com/img1.jpg");
      expect(map['images'][1]['description'], "Community room");
      expect(map['clinicalFields'][1]['clinicalFieldId'], 2);
    });

    test('fromJson maneja listas vacías y campos faltantes', () {
      final minimalJson = {
        "homeId": 0,
        "residenceName": "",
        "residenceManager": "",
        "address": "",
        "latitude": 0,
        "longitude": 0,
        "bedCount": 0,
      };
      final res = ResidenciaModel.fromJson(minimalJson);

      expect(res.availableServices, isEmpty);
      expect(res.images, isEmpty);
      expect(res.clinicalFields, isEmpty);
    });

    test('fromJsonString y toJsonString funcionan correctamente', () {
      final jsonString = jsonEncode(sampleJson);
      final res = ResidenciaModel.fromJson(jsonDecode(jsonString));
      final backToString = jsonEncode(res.toJson());
      expect(backToString, jsonEncode(res.toJson()));
    });
  });
}

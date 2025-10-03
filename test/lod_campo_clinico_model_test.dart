import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/domain/models/lodging/campo_clinico_model.dart';
import 'dart:convert';

void main() {
  group('CampoClinico', () {
    test('fromJson con int', () {
      final jsonMap = {
        "clinicalFieldId": 5,
        "clinicalFieldName": "Centro Clínico A"
      };
      final campo = CampoClinico.fromJson(jsonMap);

      expect(campo.clinicalFieldId, 5);
      expect(campo.clinicalFieldName, "Centro Clínico A");
    });

    test('fromJson con num', () {
      final jsonMap = {
        "clinicalFieldId": 5.0,
        "clinicalFieldName": "Centro Clínico B"
      };
      final campo = CampoClinico.fromJson(jsonMap);

      expect(campo.clinicalFieldId, 5);
      expect(campo.clinicalFieldName, "Centro Clínico B");
    });

    test('fromJson con String', () {
      final jsonMap = {
        "clinicalFieldId": "7",
        "clinicalFieldName": "Centro Clínico C"
      };
      final campo = CampoClinico.fromJson(jsonMap);

      expect(campo.clinicalFieldId, 7);
      expect(campo.clinicalFieldName, "Centro Clínico C");
    });

    test('fromJson con String inválido', () {
      final jsonMap = {
        "clinicalFieldId": "abc",
        "clinicalFieldName": "Centro Clínico D"
      };
      final campo = CampoClinico.fromJson(jsonMap);

      expect(campo.clinicalFieldId, 0);
    });

    test('fromJson con campo name null', () {
      final jsonMap = {"clinicalFieldId": 3, "clinicalFieldName": null};
      final campo = CampoClinico.fromJson(jsonMap);

      expect(campo.clinicalFieldName, "");
    });

    test('toJson funciona correctamente', () {
      final campo = CampoClinico(clinicalFieldId: 9, clinicalFieldName: "Centro X");
      final map = campo.toJson();

      expect(map['clinicalFieldId'], 9);
      expect(map['clinicalFieldName'], "Centro X");
    });

    test('fromJsonString y toJsonString funcionan', () {
      final jsonMap = {
        "clinicalFieldId": "12",
        "clinicalFieldName": "Centro Y"
      };
      final jsonString = jsonEncode(jsonMap);

      final campo = CampoClinico.fromJson(jsonDecode(jsonString));
      expect(campo.clinicalFieldId, 12);
      expect(campo.clinicalFieldName, "Centro Y");

      final backToString = jsonEncode(campo.toJson());
      expect(backToString, '{"clinicalFieldId":12,"clinicalFieldName":"Centro Y"}');
    });
  });
}

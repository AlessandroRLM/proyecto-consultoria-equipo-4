import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import 'package:mobile/domain/models/user/student_model.dart';

void main() {
  group('StudentModel', () {
    final jsonMap = {
      "id": 1,
      "rut": "11111111-1",
      "name": "Carlos",
      "last_name": "González",
      "condition": "Interno",
      "profession": "Medicina",
      "mobile": "No",
      "state": "Activo",
      "sede_id": 2,
      "user_id": 1001,
      "group_id": 7,
      "accept_rul": "Sí",
    };

    // este es un mapa json de ejemplo para las pruebas

    test('verificar si fromJson crea un objeto correctamente', () {
      final student = StudentModel.fromJson(jsonMap);

      expect(student.id, 1);
      expect(student.rut, "11111111-1");
      expect(student.name, "Carlos");
      expect(student.lastName, "González");
      expect(student.condition, "Interno");
      expect(student.profession, "Medicina");
      expect(student.mobile, "No");
      expect(student.state, "Activo");
      expect(student.sedeId, 2);
      expect(student.userId, 1001);
      expect(student.groupId, 7);
      expect(student.acceptRul, "Sí");

      // se crea un StudentModel desde jsonMap y se verifica que todos los campos son correctos

    });

    test('verificar si toJson devuelve el mismo mapa', () {
      final student = StudentModel.fromJson(jsonMap);
      final result = student.toJson();

      expect(result, jsonMap);

      // se crea un StudentModel desde jsonMap y luego se convierte de nuevo a mapa
      // y luego se verifica que el mapa resultante es igual al original jsonMap

    });

    test('verificar si fromJsonString y toJsonString funcionan bien', () {
      final jsonString = jsonEncode(jsonMap);
      final student = StudentModel.fromJsonString(jsonString);

      expect(student.name, "Carlos");
      expect(student.lastName, "González");

      final backToString = student.toJsonString();
      final decoded = jsonDecode(backToString) as Map<String, dynamic>;

      expect(decoded, jsonMap);

      // se convierte jsonMap a string y se crea un StudentModel desde ese string
      // luego se verifica que los campos name y lastName son correctos

    });

    test('verificar si se manejan valores diferentes de forma correcta', () {
      final altered = {...jsonMap, "state": "Suspendido"};
      final student = StudentModel.fromJson(altered);

      expect(student.state, "Suspendido");
      expect(student.state == "Activo", false);

      // en altered se copia todo el contenido de jsonMap y se cambia el estado a "Suspendido"
      // y se verifica que el estado del objeto student es "Suspendido" y no "Activo"
    });

    test('lanza excepción si falta un campo requerido', () {
      final incomplete = {...jsonMap}..remove('name');

      expect(
        () => StudentModel.fromJson(incomplete),
        throwsA(isA<TypeError>()),
      );

      // se crea una copia de jsonMap y se elimina el campo 'name'
      // luego se verifica que al intentar crear un StudentModel con este mapa incompleto lance una excepción de tipo TypeError
    });
        test('lanza excepción si un campo requerido es nulo', () {
      final withNull = {...jsonMap, "last_name": null};

      expect(
        () => StudentModel.fromJson(withNull),
        throwsA(isA<TypeError>()),
      );

      // se crea una copia de jsonMap y se asigna null al campo 'last_name'
      // luego se verifica que al intentar crear un StudentModel con este mapa que tiene un campo nulo lance una excepción de tipo TypeError

    });

  });
  
}

import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import 'package:mobile/domain/models/user/student_profile_model.dart';

void main() {
  group('StudentProfileModel', () {
    final userJson = {
      "id": "1",
      "email": "carlos.gonzalez@example.com",
      "password": "123456",
      "name": "Carlos",
      "rut": "11111111-1",
      "a_carrera": 3,
      "sede": "Santiago",
      "services_id": "2",
      "avatar_url":
          "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png",
    };

    final studentJson = {
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

    final profileJson = {
      "user": userJson,
      "student": studentJson,
    };

    test('fromJson crea StudentProfileModel correctamente', () {
      final profile = StudentProfileModel.fromJson(profileJson);

      // se verifica el user
      expect(profile.user.id, "1");
      expect(profile.user.email, "carlos.gonzalez@example.com");
      expect(profile.user.name, "Carlos");
      expect(profile.user.sede, "Santiago");

      // se verifica student
      expect(profile.student.id, 1);
      expect(profile.student.name, "Carlos");
      expect(profile.student.lastName, "González");
      expect(profile.student.profession, "Medicina");
      expect(profile.student.state, "Activo");
    });

    test('toJson devuelve el mismo mapa', () {
      final profile = StudentProfileModel.fromJson(profileJson);
      expect(profile.toJson(), profileJson);
    });

    test('fromJsonString y toJsonString funcionan correctamente', () {
      final jsonString = jsonEncode(profileJson);
      final profile = StudentProfileModel.fromJsonString(jsonString);

      expect(profile.user.email, "carlos.gonzalez@example.com");
      expect(profile.student.groupId, 7);

      final backToString = profile.toJsonString();
      final decoded = jsonDecode(backToString) as Map<String, dynamic>;
      expect(decoded, profileJson);
    });

    test('lanza excepción si falta user', () {
      final invalid = {...profileJson}..remove("user");

      expect(
        () => StudentProfileModel.fromJson(invalid),
        throwsA(isA<TypeError>()),
      );
    });
    // se crea un mapa json sin la clave 'user' y se verifica que
    // StudentProfileModel.fromJson lanza una TypeError

    test('lanza excepción si falta student', () {
      final invalid = {...profileJson}..remove("student");

      expect(
        () => StudentProfileModel.fromJson(invalid),
        throwsA(isA<TypeError>()),
      );
    });

    test('lanza excepción si user no es un mapa', () {
      final invalid = {...profileJson, "user": "string en vez de mapa"};

      expect(
        () => StudentProfileModel.fromJson(invalid),
        throwsA(isA<TypeError>()),
      );
    });

    test('lanza excepción si student no es un mapa', () {
      final invalid = {...profileJson, "student": "string en vez de mapa"};

      expect(
        () => StudentProfileModel.fromJson(invalid),
        throwsA(isA<TypeError>()),
      );
    });
  });
}
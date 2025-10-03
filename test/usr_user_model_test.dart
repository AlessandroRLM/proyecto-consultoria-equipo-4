import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import 'package:mobile/domain/models/user/user_model.dart';

void main() {
  group('UserModel', () {
    final jsonMap = {
      "id": "1",
      "email": "carlos.gonzalez@example.com",
      "password": "123456",
      "name": "Carlos",
      "rut": "11111111-1",
      "a_carrera": 3,
      "sede": "Santiago",
      "services_id": "2",
      "avatar_url": "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png",
    };
// este es un mapa json de ejemplo para las pruebas, se utilizan los datos de student.json
    test('fromJson crea un UserModel correctamente', () {
      final user = UserModel.fromJson(jsonMap);

      expect(user.id, "1");
      expect(user.email, "carlos.gonzalez@example.com");
      expect(user.password, "123456");
      expect(user.name, "Carlos");
      expect(user.rut, "11111111-1");
      expect(user.aCarrera, 3);
      expect(user.sede, "Santiago");
      expect(user.servicesId, "2");
      expect(user.avatarUrl, "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png");
    });

    // se crea un UserModel desde jsonMap y se verifica que todos los campos son correctos

    test('toJson devuelve el mismo mapa', () {
      final user = UserModel.fromJson(jsonMap);
      expect(user.toJson(), jsonMap);
    });

    // se crea un UserModel desde jsonMap y luego se convierte de nuevo a mapa
    // y luego se verifica que el mapa resultante es igual al original jsonMap

    test('fromJsonString y toJsonString funcionan bien', () {
      final jsonString = jsonEncode(jsonMap);
      final user = UserModel.fromJsonString(jsonString);

      expect(user.email, "carlos.gonzalez@example.com");
      expect(user.sede, "Santiago");

      final backToString = user.toJsonString();
      final decoded = jsonDecode(backToString) as Map<String, dynamic>;
      expect(decoded, jsonMap);
    });

    // se convierte jsonMap a cadena json, se crea un UserModel desde esa cadena
    // y se verifica que algunos campos son correctos

    test('acepta claves alternativas para id, aCarrera, servicesId, avatarUrl', () {
      final altJson = {
        "user_id": "2",
        "email": "alt@example.com",
        "password": "pass",
        "name": "Juan",
        "rut": "98765432-1",
        "aCarrera": 4,
        "sede": "Valparaíso",
        "servicesId": "3",
        "avatarUrl": "alt.png",
      };

      final user = UserModel.fromJson(altJson);

      expect(user.id, "2");
      expect(user.aCarrera, 4);
      expect(user.servicesId, "3");
      expect(user.avatarUrl, "alt.png");
    });

    // se crea un mapa json con claves alternativas y se verifica que
    // UserModel.fromJson las interpreta bien

    test('usa password vacío si falta en el JSON', () {
      final noPasswordJson = {...jsonMap}..remove("password");

      final user = UserModel.fromJson(noPasswordJson);
      expect(user.password, "");
    });

    // se crea un mapa json sin la clave 'password' y se verifica que
    // UserModel.fromJson asigna una cadena vacía a password
    
  });
}
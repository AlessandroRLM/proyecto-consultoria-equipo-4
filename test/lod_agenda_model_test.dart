import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/domain/models/lodging/agenda_model.dart';
import 'package:mobile/domain/models/lodging/estado_agenda.dart';


void main() {
  group('AgendaModel QA Completo', () {
    // JSON normal
    final jsonMap = {
      "id": 1,
      "student_id": 1001,
      "occupant_name": "Carlos González",
      "occupant_mobile": "999999999",
      "occupant_kind": "Interna",
      "reservation_date": "2025-09-30",
      "reservation_init": "08:30",
      "reservation_fin": "10:30",
      "clinical_name": "Providencia Healthcare Center",
      "home_id": 101,
      "state": "Activa",
    };

    // JSON con strings vacíos
    final jsonEmptyStrings = {
      "id": "",
      "student_id": "",
      "occupant_name": "",
      "occupant_mobile": "",
      "occupant_kind": "",
      "reservation_date": "",
      "reservation_init": "",
      "reservation_fin": "",
      "clinical_name": "",
      "home_id": "",
      "state": "",
    };

    // JSON con tipos incorrectos
    final jsonWrongTypes = {
      "id": "abc",
      "student_id": "xyz",
      "home_id": "!!!",
      "state": 123, // int en lugar de string
    };

    test('fromJson asigna correctamente los campos normales', () {
      final agenda = AgendaModel.fromJson(jsonMap);
      expect(agenda.id, 1);
      expect(agenda.studentId, 1001);
      expect(agenda.state, EstadoAgenda.activa);
    });

    test('toJson mantiene coherencia con fromJson', () {
      final agenda = AgendaModel.fromJson(jsonMap);
      final jsonOut = agenda.toJson();
      expect(jsonOut['state'], 'Activa');
      expect(jsonOut['id'], 1);
    });

    test('startDateTime y endDateTime combinan fecha y hora', () {
      final agenda = AgendaModel.fromJson(jsonMap);
      expect(agenda.startDateTime, DateTime(2025, 9, 30, 8, 30));
      expect(agenda.endDateTime, DateTime(2025, 9, 30, 10, 30));
    });

    test('fromJson con strings vacíos convierte enteros a 0 y estado a activo', () {
      final agenda = AgendaModel.fromJson(jsonEmptyStrings);
      expect(agenda.id, 0);
      expect(agenda.studentId, 0);
      expect(agenda.homeId, 0);
      expect(agenda.state, EstadoAgenda.activa); // fallback
    });

    test('fromJson con tipos incorrectos convierte enteros a 0 y estado a activo', () {
      final agenda = AgendaModel.fromJson(jsonWrongTypes);
      expect(agenda.id, 0);
      expect(agenda.studentId, 0);
      expect(agenda.homeId, 0);
      expect(agenda.state, EstadoAgenda.activa);
    });

    test('EstadoAgendaX.fromJson tolera variantes y typos', () {
      expect(EstadoAgendaX.fromJson('Iniciada'), EstadoAgenda.iniciada);
      expect(EstadoAgendaX.fromJson('Pendiente'), EstadoAgenda.pendiente);
      expect(EstadoAgendaX.fromJson('Activa'), EstadoAgenda.activa); 
    });
  });
}

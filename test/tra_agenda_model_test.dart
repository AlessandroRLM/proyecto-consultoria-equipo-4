import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import 'package:mobile/domain/models/transport/agenda_model.dart';
import 'package:mobile/domain/models/transport/driver_model.dart';
import 'package:mobile/domain/models/transport/gps_model.dart';
void main() {
  group('TransportAgendaModel', () {
    final vehicleJson = {
      "plate": "ABC123",
      "model": "Toyota Corolla",
      "type": "Sedán"
    };

    final driverJson = {
      "name": "Juan Pérez",
      "license": "ABC12345",
      "contact": "+56987654321"
    };

    final gpsJson = {
      "latitude": 12.3456,
      "longitude": -76.5432,
      "timestamp": "2025-09-29T12:34:56.000Z"
    };

    final jsonMap = {
      "agenda_id": 1,
      "service_name": "Transporte Clínico",
      "date": "29-09-2025",
      "clinical_field": "Centro Clínico",
      "sede": "Santa Juana",
      "trip_type": "ida",
      "departure_time": "08:00",
      "vehicle": vehicleJson,
      "driver": driverJson,
      "gps": gpsJson,
    };

    test('fromJson crea correctamente el modelo', () {
      final agenda = TransportAgendaModel.fromJson(jsonMap);

      expect(agenda.agendaId, 1);
      expect(agenda.serviceName, "Transporte Clínico");
      expect(agenda.date, DateTime(2025, 9, 29));
      expect(agenda.vehicle.plate, "ABC123");
      expect(agenda.driver, isA<DriverModel>());
      expect(agenda.gps, isA<GpsPositionModel>());
    });

    test('toJson devuelve el mismo mapa (fecha formateada)', () {
      final agenda = TransportAgendaModel.fromJson(jsonMap);
      final toJson = agenda.toJson();

      expect(toJson['agenda_id'], 1);
      expect(toJson['date'], "29-09-2025");
      expect(toJson['vehicle']['plate'], "ABC123");
      expect(toJson['driver']['name'], "Juan Pérez");
      expect(toJson['gps']['latitude'], 12.3456);
    });

    test('campos opcionales driver y gps pueden ser null', () {
      final jsonNoOptional = {...jsonMap}..remove('driver')..remove('gps');
      final agenda = TransportAgendaModel.fromJson(jsonNoOptional);

      expect(agenda.driver, null);
      expect(agenda.gps, null);
    });

    test('listFromJsonList y listFromRoot funcionan correctamente', () {
      final list = TransportAgendaModel.listFromJsonList([jsonMap, jsonMap]);
      expect(list.length, 2);
      expect(list[1].serviceName, "Transporte Clínico");

      final root = {"agendas_en_curso": [jsonMap, jsonMap]};
      final list2 = TransportAgendaModel.listFromRoot(root);
      expect(list2.length, 2);
    });

    test('listFromJsonString funciona correctamente', () {
      final rootJson = {"agendas_en_curso": [jsonMap]};
      final jsonString = jsonEncode(rootJson);
      final list = TransportAgendaModel.listFromJsonString(jsonString);

      expect(list.length, 1);
      expect(list[0].vehicle.model, "Toyota Corolla");
    });

    test('lanza TypeError si falta clave obligatoria', () {
      final incomplete = {...jsonMap}..remove('agenda_id');
      expect(() => TransportAgendaModel.fromJson(incomplete), throwsA(isA<TypeError>()));
    });

    test('lanza TypeError si tipo incorrecto', () {
      final wrongType = {...jsonMap, 'agenda_id': 'uno'};
      expect(() => TransportAgendaModel.fromJson(wrongType), throwsA(isA<TypeError>()));
    });
  });
}

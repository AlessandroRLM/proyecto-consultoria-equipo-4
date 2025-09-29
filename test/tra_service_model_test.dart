import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import 'package:mobile/domain/models/transport/service_model.dart';

void main() {
  group('ItineraryStopModel', () {
    test('fromJson y toJson funcionan correctamente', () {
      final jsonMap = {
        "campus_id": 1,
        "name": "Campus Santiago",
      };

      final stop = ItineraryStopModel.fromJson(jsonMap);
      expect(stop.campusId, 1);
      expect(stop.clinicalId, null);
      expect(stop.name, "Campus Santiago");

      final toJson = stop.toJson();
      expect(toJson, jsonMap);
    });

    test('fromJson con clinicalId', () {
      final jsonMap = {
        "clinical_id": 5,
        "name": "Centro Clínico",
      };

      final stop = ItineraryStopModel.fromJson(jsonMap);
      expect(stop.campusId, null);
      expect(stop.clinicalId, 5);
      expect(stop.name, "Centro Clínico");

      final toJson = stop.toJson();
      expect(toJson, jsonMap);
    });

    test('lanza TypeError si falta name', () {
      final incomplete = {"campus_id": 1};
      expect(() => ItineraryStopModel.fromJson(incomplete), throwsA(isA<TypeError>()));
    });
  });

  group('TransportServiceModel', () {
    final itineraryJson = [
      {"campus_id": 1, "name": "Campus Santiago"},
      {"clinical_id": 5, "name": "Centro Clínico"},
    ];

    final jsonMap = {
      "id": 100,
      "name": "Servicio 1",
      "name_itinerary": "Itinerario A",
      "type_service": "IDA",
      "departure": "08:30:00",
      "mon_trip": 1,
      "tue_trip": 0,
      "wed_trip": true,
      "thu_trip": false,
      "fri_trip": 1,
      "sat_trip": 0,
      "sun_trip": 1,
      "clinal_id": 2,
      "sede_id": 1,
      "itinerario": itineraryJson,
    };

    test('fromJson crea correctamente el modelo', () {
      final service = TransportServiceModel.fromJson(jsonMap);

      expect(service.id, 100);
      expect(service.name, "Servicio 1");
      expect(service.typeService, "IDA");
      expect(service.monTrip, true);
      expect(service.tueTrip, false);
      expect(service.wedTrip, true);
      expect(service.itinerary.length, 2);
      expect(service.itinerary[0].name, "Campus Santiago");
      expect(service.itinerary[1].clinicalId, 5);
    });

    test('toJson devuelve el mismo mapa (con 1/0 para booleanos)', () {
      final service = TransportServiceModel.fromJson(jsonMap);
      final toJson = service.toJson();

      expect(toJson['mon_trip'], 1);
      expect(toJson['tue_trip'], 0);
      expect(toJson['wed_trip'], 1);
      expect(toJson['itinerario'].length, 2);
      expect(toJson['itinerario'][0]['name'], "Campus Santiago");
    });

    test('listFromJsonString convierte lista JSON correctamente', () {
      final jsonString = jsonEncode([jsonMap, jsonMap]);
      final list = TransportServiceModel.listFromJsonString(jsonString);

      expect(list.length, 2);
      expect(list[0].name, "Servicio 1");
      expect(list[1].itinerary[1].name, "Centro Clínico");
    });

    test('lanza TypeError si falta clave obligatoria', () {
      final incomplete = {...jsonMap}..remove('id');
      expect(() => TransportServiceModel.fromJson(incomplete), throwsA(isA<TypeError>()));
    });

    test('lanza TypeError si tipo incorrecto', () {
      final wrongType = {...jsonMap, 'mon_trip': 'sí'};
      expect(() => TransportServiceModel.fromJson(wrongType), throwsA(isA<TypeError>()));
    });
  });
}

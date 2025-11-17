import 'package:mobile/adapters/transport/driven/providers/transport_reservations_provider.dart';
import 'package:mobile/domain/models/transport/agenda_model.dart';
import 'package:mobile/domain/models/transport/service_model.dart';
import 'package:mobile/ports/transport/driven/for_querying_transport.dart';

class LocalTransportRepository implements ForQueryingTransport {
  final TransportReservationsProvider reservationsProvider;

  LocalTransportRepository({
    required this.reservationsProvider,
  });

  @override
  Future<List<TransportAgendaModel>> getStudentAgenda(TransportAgendaQuery query) async {
    await reservationsProvider.fetchReservations();
    final agendas = _mapReservationsToAgenda();
    return agendas.where((agenda) {
      if (query.from != null && agenda.date.isBefore(query.from!)) {
        return false;
      }
      if (query.to != null && agenda.date.isAfter(query.to!)) {
        return false;
      }
      if (query.onlyActive) {
        //usar estado real cuando exista
      }
      //filtrar por studentId cuando el provider lo exponga
      return true;
    }).toList();
  }

  @override
  Future<TransportAgendaModel?> getAgendaById(int agendaId) async {
    await reservationsProvider.fetchReservations();
    final agendas = _mapReservationsToAgenda();
    for (final agenda in agendas) {
      if (agenda.agendaId == agendaId) {
        return agenda;
      }
    }
    return null;
  }

//filtrar por fechas/campus cuando aplique
  @override
  Future<List<TransportServiceModel>> getServices(TransportServiceQuery query) async {
    final services = _mockServices
        .map((json) => TransportServiceModel.fromJson(json))
        .toList();
    return services.where((service) {
      if (query.sedeId != null && service.sedeId != query.sedeId) {
        return false;
      }
      if (query.clinicalId != null && service.clinalId != query.clinicalId) {
        return false;
      }
      if (query.outboundTrip != null) {
        final isOutbound = service.typeService.toLowerCase() == 'ida';
        if (isOutbound != query.outboundTrip!) {
          return false;
        }
      }
      if (query.campusId != null) {
        final stopIds = service.itinerary
            .map((stop) => stop.campusId)
            .where((id) => id != null)
            .toList();

        if (!stopIds.contains(query.campusId)) return false;
      }
      return true; 
    }).toList();
  }

  @override
  Future<TransportServiceModel?> getServiceById(int serviceId) async {
    final services = await getServices(const TransportServiceQuery());
    for (final service in services) {
      if (service.id == serviceId) {
        return service;
      }
    }
    return null;
  }

  //contar reservas reales por servicio/fecha
  @override
  Future<bool> hasAvailability({required int serviceId, required DateTime date}) async {
    return true;
  }

  @override
  Future<TransportAgendaModel> createReservation({
    required int serviceId,
    required DateTime date,
  }) async {
    await reservationsProvider.fetchReservations();
    final reservation = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'outbound': {
        'date': _formatIso(date),
        'origin': 'Campus Universidad',
        'destination': 'Campo Clinico',
        'originTime': '08:00',
        'service': 'Servicio $serviceId',
        'details': 'IDA',
      },
      'return': null,
    };
    final updated = List<Map<String, dynamic>>.from(reservationsProvider.reservations)
      ..add(reservation);
    reservationsProvider.updateReservations(updated);
    final outbound = reservation['outbound'] as Map<String, dynamic>;
    return _mapLegToAgenda(outbound, reservation['id'], true);
  }

  @override
  Future<void> cancelReservation(int agendaId) async {
    await reservationsProvider.fetchReservations();
    final updated = List<Map<String, dynamic>>.from(reservationsProvider.reservations);
    bool changed = false;
    for (var i = updated.length - 1; i >= 0; i--) {
      final reservation = updated[i];
      final rawId = reservation['id'];
      if (_matchesLeg(reservation['outbound'], rawId, true, agendaId)) {
        reservation['outbound'] = null;
        changed = true;
      }
      if (_matchesLeg(reservation['return'], rawId, false, agendaId)) {
        reservation['return'] = null;
        changed = true;
      }
      if (reservation['outbound'] == null && reservation['return'] == null) {
        updated.removeAt(i);
      }
    }
    if (changed) {
      reservationsProvider.updateReservations(updated);
    }
  }

  List<TransportAgendaModel> _mapReservationsToAgenda() {
    final List<TransportAgendaModel> agendas = [];
    for (final reservation in reservationsProvider.reservations) {
      final rawId = reservation['id'];
      final outbound = reservation['outbound'] as Map<String, dynamic>?;
      final returnLeg = reservation['return'] as Map<String, dynamic>?;
      if (outbound != null) {
        agendas.add(_mapLegToAgenda(outbound, rawId, true));
      }
      if (returnLeg != null) {
        agendas.add(_mapLegToAgenda(returnLeg, rawId, false));
      }
    }
    return agendas;
  }

  TransportAgendaModel _mapLegToAgenda(
    Map<String, dynamic> leg,
    dynamic rawId,
    bool isOutbound,
  ) {
    final dateStr = leg['date'] as String?;
    final parsedDate = dateStr != null ? DateTime.tryParse(dateStr) : null;
    final json = {
      'agenda_id': _buildAgendaId(rawId, isOutbound),
      'service_name': leg['service'] ?? 'Transporte',
      'date': _formatDmy(parsedDate ?? DateTime.now()),
      'clinical_field': leg['destination'] ?? 'Campo Clinico',
      'sede': leg['origin'] ?? 'Campus',
      'trip_type': isOutbound ? 'ida' : 'regreso',
      'departure_time': leg['originTime'] ?? '08:00',
      'vehicle': {
        'plate': 'XXX-000',
        'model': 'Bus',
        'type': 'Transporte',
      },
    };
    return TransportAgendaModel.fromJson(json);
  }

  bool _matchesLeg(
    dynamic leg,
    dynamic rawId,
    bool isOutbound,
    int agendaId,
  ) {
    if (leg == null) return false;
    return _buildAgendaId(rawId, isOutbound) == agendaId;
  }

  int _buildAgendaId(dynamic rawId, bool isOutbound) {
    if (rawId is int) {
      return isOutbound ? rawId : rawId + 1;
    }
    if (rawId is String) {
      final parsed = int.tryParse(rawId);
      if (parsed != null) {
        return isOutbound ? parsed : parsed + 1;
      }
      return isOutbound ? rawId.hashCode : rawId.hashCode + 1;
    }
    return isOutbound ? rawId.hashCode : rawId.hashCode + 1;
  }

  String _formatIso(DateTime date) {
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '${date.year}-$m-$d';
  }

  String _formatDmy(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d-$m-${date.year}';
  }

  List<Map<String, dynamic>> get _mockServices => [
    //ida
    {
      "id": 301,
      "name": "ITINERARIO CALLE NUEVA",
      "name_itinerary": "SANTA JUANA - CESFAM ESMERALDA - CESCOF COI IDA",
      "type_service": "IDA",
      "departure": "01:30:00",
      "mon_trip": 1,
      "tue_trip": 1,
      "wed_trip": 1,
      "thu_trip": 1,
      "fri_trip": 0,
      "sat_trip": 0,
      "sun_trip": 0,
      "clinal_id": 21,
      "sede_id": 6,
      "itinerario": [
        {
          "campus_id": 10,
          "name": "Campus Santa Juana"
        },
        {
          "clinical_id": 21,
          "name": "CLÍNICA SAN MARTÍN"
        },
        {
          "clinical_id": 22,
          "name": "HOSPITAL FAMILIAR MAIPÚ"
        }
      ]
    },
    {
      "id": 302,
      "name": "ITINERARIO CALLE NUEVA",
      "name_itinerary": "SANTA JUANA - CESFAM ESMERALDA - CESCOF COI IDA",
      "type_service": "IDA",
      "departure": "06:30:00",
      "mon_trip": 1,
      "tue_trip": 1,
      "wed_trip": 1,
      "thu_trip": 1,
      "fri_trip": 0,
      "sat_trip": 0,
      "sun_trip": 0,
      "clinal_id": 21,
      "sede_id": 6,
      "itinerario": [
        {
          "campus_id": 10,
          "name": "Campus Santa Juana"
        },
        {
          "clinical_id": 21,
          "name": "CLÍNICA SAN MARTÍN"
        },
        {
          "clinical_id": 22,
          "name": "HOSPITAL FAMILIAR MAIPÚ"
        }
      ]
    },
    {
      "id": 303,
      "name": "ITINERARIO CALLE NUEVA",
      "name_itinerary": "SANTA JUANA - CESFAM ESMERALDA - CESCOF COI IDA",
      "type_service": "IDA",
      "departure": "08:30:00",
      "mon_trip": 1,
      "tue_trip": 1,
      "wed_trip": 1,
      "thu_trip": 1,
      "fri_trip": 0,
      "sat_trip": 0,
      "sun_trip": 0,
      "clinal_id": 21,
      "sede_id": 6,
      "itinerario": [
        {
          "campus_id": 10,
          "name": "Campus Santa Juana"
        },
        {
          "clinical_id": 21,
          "name": "CLÍNICA SAN MARTÍN"
        },
        {
          "clinical_id": 22,
          "name": "HOSPITAL FAMILIAR MAIPÚ"
        }
      ]
    },
    {
      "id": 304,
      "name": "ITINERARIO CALLE NUEVA",
      "name_itinerary": "SANTA JUANA - CESFAM ESMERALDA - CESCOF COI IDA",
      "type_service": "IDA",
      "departure": "10:30:00",
      "mon_trip": 1,
      "tue_trip": 1,
      "wed_trip": 1,
      "thu_trip": 1,
      "fri_trip": 0,
      "sat_trip": 0,
      "sun_trip": 0,
      "clinal_id": 21,
      "sede_id": 6,
      "itinerario": [
        {
          "campus_id": 10,
          "name": "Campus Santa Juana"
        },
        {
          "clinical_id": 21,
          "name": "CLÍNICA SAN MARTÍN"
        },
        {
          "clinical_id": 22,
          "name": "HOSPITAL FAMILIAR MAIPÚ"
        }
      ]
    },
    {
      "id": 305,
      "name": "ITINERARIO CALLE NUEVA",
      "name_itinerary": "SANTA JUANA - CESFAM ESMERALDA - CESCOF COI IDA",
      "type_service": "IDA",
      "departure": "11:00:00",
      "mon_trip": 1,
      "tue_trip": 1,
      "wed_trip": 1,
      "thu_trip": 1,
      "fri_trip": 0,
      "sat_trip": 0,
      "sun_trip": 0,
      "clinal_id": 21,
      "sede_id": 6,
      "itinerario": [
        {
          "campus_id": 10,
          "name": "Campus Santa Juana"
        },
        {
          "clinical_id": 21,
          "name": "CLÍNICA SAN MARTÍN"
        },
        {
          "clinical_id": 22,
          "name": "HOSPITAL FAMILIAR MAIPÚ"
        }
      ]
    },
    {
      "id": 306,
      "name": "ITINERARIO CALLE NUEVA",
      "name_itinerary": "SANTA JUANA - CESFAM ESMERALDA - CESCOF COI IDA",
      "type_service": "IDA",
      "departure": "11:30:00",
      "mon_trip": 1,
      "tue_trip": 1,
      "wed_trip": 1,
      "thu_trip": 1,
      "fri_trip": 0,
      "sat_trip": 0,
      "sun_trip": 0,
      "clinal_id": 21,
      "sede_id": 6,
      "itinerario": [
        {
          "campus_id": 10,
          "name": "Campus Santa Juana"
        },
        {
          "clinical_id": 21,
          "name": "CLÍNICA SAN MARTÍN"
        },
        {
          "clinical_id": 22,
          "name": "HOSPITAL FAMILIAR MAIPÚ"
        }
      ]
    },
     {
      "id": 307,
      "name": "ITINERARIO CALLE NUEVA",
      "name_itinerary": "All",
      "type_service": "IDA",
      "departure": "12:30:00",
      "mon_trip": 1,
      "tue_trip": 1,
      "wed_trip": 1,
      "thu_trip": 1,
      "fri_trip": 1,
      "sat_trip": 0,
      "sun_trip": 0,
      "clinal_id": 21,
      "sede_id": 6,
      "itinerario": [
        {
          "clinical_id": 21,
          "name": "CLÍNICA SAN MARTÍN"
        },
        {
          "clinical_id": 22,
          "name": "HOSPITAL FAMILIAR MAIPÚ"
        },
        {
          "clinical_id": 23,
          "name": "CESFAM PUERTO VARAS"
        },
        {
          "clinical_id": 24,
          "name": "CESFAM PARQUE O'HIGGINS"
        },
        {
          "clinical_id": 25,
          "name": "HOSPITAL QUILPUÉ"
        }
      ]
    },
    //regreso
    {
      "id": 311,
      "name": "REGRESO NUEVA",
      "name_itinerary": "SANTA JUANA - CESFAM RAUL BREGUET REGRESO",
      "type_service": "REGRESO",
      "departure": "16:00:00",
      "mon_trip": 0,
      "tue_trip": 1,
      "wed_trip": 1,
      "thu_trip": 1,
      "fri_trip": 1,
      "sat_trip": 0,
      "sun_trip": 0,
      "clinal_id": 21,
      "sede_id": 6,
      "itinerario": [
        {
          "clinical_id": 21,
          "name": "CLÍNICA SAN MARTÍN"
        },
        {
          "clinical_id": 23,
          "name": "CESFAM PUERTO VARAS"
        },
        {
          "campus_id": 10,
          "name": "Campus Santa Juana"
        }
      ]
    },
    {
      "id": 312,
      "name": "REGRESO NUEVA",
      "name_itinerary": "All",
      "type_service": "REGRESO",
      "departure": "21:00:00",
      "mon_trip": 1,
      "tue_trip": 1,
      "wed_trip": 1,
      "thu_trip": 1,
      "fri_trip": 1,
      "sat_trip": 0,
      "sun_trip": 0,
      "clinal_id": 21,
      "sede_id": 6,
      "itinerario": [
        {
          "clinical_id": 21,
          "name": "CLÍNICA SAN MARTÍN"
        },
        {
          "clinical_id": 22,
          "name": "HOSPITAL FAMILIAR MAIPÚ"
        },
        {
          "clinical_id": 23,
          "name": "CESFAM PUERTO VARAS"
        },
        {
          "clinical_id": 24,
          "name": "CESFAM PARQUE O'HIGGINS"
        },
        {
          "clinical_id": 25,
          "name": "HOSPITAL QUILPUÉ"
        }
      ]
    },
    
  ];
}

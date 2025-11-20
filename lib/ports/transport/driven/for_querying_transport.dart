import 'package:mobile/domain/models/transport/agenda_model.dart';
import 'package:mobile/domain/models/transport/service_model.dart';

/// ----------------------------------------------
/// QUERY OBJECTS
/// ----------------------------------------------

/// Filtros para buscar servicios publicados.
class TransportServiceQuery {
  final int? sedeId;
  final int? campusId;
  final int? clinicalId;
  final bool? outboundTrip; // true = ida, false = regreso, null = cualquiera
  final DateTime? from;
  final DateTime? to;

  const TransportServiceQuery({
    this.sedeId,
    this.campusId,
    this.clinicalId,
    this.outboundTrip,
    this.from,
    this.to,
  });

  TransportServiceQuery copyWith({
    int? sedeId,
    int? campusId,
    int? clinicalId,
    bool? outboundTrip,
    DateTime? from,
    DateTime? to,
  }) {
    return TransportServiceQuery(
      sedeId: sedeId ?? this.sedeId,
      campusId: campusId ?? this.campusId,
      clinicalId: clinicalId ?? this.clinicalId,
      outboundTrip: outboundTrip ?? this.outboundTrip,
      from: from ?? this.from,
      to: to ?? this.to,
    );
  }
}

/// Filtros para consultar la agenda del estudiante.
class TransportAgendaQuery {
  final String studentId;
  final DateTime? from;
  final DateTime? to;
  final bool onlyActive;

  const TransportAgendaQuery({
    required this.studentId,
    this.from,
    this.to,
    this.onlyActive = true,
  });

  TransportAgendaQuery copyWith({
    String? studentId,
    DateTime? from,
    DateTime? to,
    bool? onlyActive,
  }) {
    return TransportAgendaQuery(
      studentId: studentId ?? this.studentId,
      from: from ?? this.from,
      to: to ?? this.to,
      onlyActive: onlyActive ?? this.onlyActive,
    );
  }
}


abstract class ForQueryingTransport {
  // READ (consultas)
  /// Obtiene la agenda del estudiante según filtros.
  Future<List<TransportAgendaModel>> getStudentAgenda(
    TransportAgendaQuery query,
  );

  /// Obtiene una reserva específica por ID.
  Future<TransportAgendaModel?> getAgendaById(int agendaId);

  /// Obtiene servicios disponibles según filtros.
  Future<List<TransportServiceModel>> getServices(
    TransportServiceQuery query,
  );

  /// Obtiene un servicio específico por ID.
  Future<TransportServiceModel?> getServiceById(int serviceId);

  /// Verifica disponibilidad para un servicio en una fecha.
  Future<bool> hasAvailability({
    required int serviceId,
    required DateTime date,
  });

  // WRITE (crear y eliminar)
  /// Crea una nueva reserva (ida o regreso) para un servicio en una fecha.
  Future<TransportAgendaModel> createReservation({
    required int serviceId,
    required DateTime date,
  });

  /// Cancela una reserva existente según su ID.
  Future<void> cancelReservation(int agendaId);
}

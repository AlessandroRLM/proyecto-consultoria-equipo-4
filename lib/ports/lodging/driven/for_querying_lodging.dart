import 'package:mobile/domain/models/lodging/agenda_model.dart';
import 'package:mobile/domain/models/lodging/residencia_model.dart';

/// Puerto DRIVEN para consultar información de alojamiento.
/// La UI sólo ve esta interfaz, no sabe si viene de JSON, API, etc.
abstract class ForQueryingLodging {
  /// Agendas (reservas) del estudiante actual.
  Future<List<AgendaModel>> getStudentAgendas();

  /// Ocupaciones de las residencias para el calendario.
  Future<List<Map<String, dynamic>>> getOccupiedReservationsForCalendar();

  /// Todas las residencias disponibles.
  Future<List<ResidenciaModel>> getResidences();

  /// Detalle de una residencia por ID.
  Future<ResidenciaModel> getResidenceById(int homeId);

  /// El mapa puede contener claves como: 'city', 'commune', etc.
  /// Si no se encuentra, devuelve null.
  Future<Map<String, String>?> getClinicInfoByName(String clinicalName);
}

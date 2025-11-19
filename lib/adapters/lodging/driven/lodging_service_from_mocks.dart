import 'package:mobile/adapters/lodging/driven/datasources/lodging_mock_datasource.dart';
import 'package:mobile/domain/models/lodging/agenda_model.dart';
import 'package:mobile/domain/models/lodging/residencia_model.dart';
import 'package:mobile/ports/lodging/driven/for_querying_lodging.dart';

/// Adaptador DRIVEN que implementa el puerto usando los JSON de mocks.
/// Si hay backend real, se cambia esta clase por otra
/// implementación del mismo puerto y la UI no se entera.
class LodgingFromMocks implements ForQueryingLodging {
  final LodgingMockDataSource _ds;

  LodgingFromMocks({LodgingMockDataSource? dataSource})
    : _ds = dataSource ?? LodgingMockDataSource();

  /// Agendas (reservas) del estudiante actual.
  @override
  Future<List<AgendaModel>> getStudentAgendas() async {
    final raw = await _ds.getStudentSchedulesRaw();
    return raw.map((j) => AgendaModel.fromJson(j)).toList();
  }

  /// Todas las residencias disponibles.
  @override
  Future<List<ResidenciaModel>> getResidences() async {
    final homesRaw = await _ds.getHomesRaw();
    return homesRaw.map((h) => ResidenciaModel.fromJson(h)).toList();
  }

  /// Detalle de una residencia por ID.
  @override
  Future<ResidenciaModel> getResidenceById(int homeId) async {
    final homesRaw = await _ds.getHomesRaw();
    final json = homesRaw.firstWhere(
      (h) => (h['homeId'] as int) == homeId,
      orElse: () => throw Exception('Residencia $homeId no encontrada'),
    );
    return ResidenciaModel.fromJson(json);
  }

  /// Implementación con mocks:
  /// - Busca en `schedule.json` (getSchedulesRaw) el primer registro cuya
  ///   `clinical_name` coincida con [clinicalName].
  /// - Si el JSON trae campos `city` y `commune`, los devuelve.
  /// - Si no hay coincidencias o no tiene esos campos, retorna `null`.
  @override
  Future<Map<String, String>?> getClinicInfoByName(String clinicalName) async {
    final schedules = await _ds.getSchedulesRaw();

    // Buscamos un item cuyo nombre de clínica coincida (ignorando espacios).
    Map<String, dynamic>? match;
    for (final s in schedules) {
      final name = (s['clinical_name'] ?? '').toString().trim();
      if (name == clinicalName.trim()) {
        match = s;
        break;
      }
    }

    if (match == null) return null;

    final city = (match['city'] ?? '').toString().trim();
    final commune = (match['commune'] ?? '').toString().trim();

    if (city.isEmpty && commune.isEmpty) {
      return null;
    }

    return {
      if (city.isNotEmpty) 'city': city,
      if (commune.isNotEmpty) 'commune': commune,
    };
  }
}

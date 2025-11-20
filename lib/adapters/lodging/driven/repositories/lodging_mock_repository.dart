import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:mobile/domain/core/campus.dart';
import 'package:mobile/domain/models/lodging/estado_agenda.dart';
import 'package:mobile/ports/auth/drivers/for_authenticating_user.dart';
import 'package:mobile/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart'; // NECESARIO para la persistencia mock
import 'package:mobile/adapters/lodging/driven/datasources/lodging_mock_datasource.dart';
import 'package:mobile/domain/models/lodging/agenda_model.dart';
import 'package:mobile/domain/models/lodging/residencia_model.dart';
import 'package:mobile/ports/lodging/driven/for_persisting_reservations.dart';
import 'package:mobile/ports/lodging/driven/for_querying_lodging.dart';

/// Adaptador DRIVEN que implementa el puerto de CONSULTA y PERSISTENCIA para el lodging.
class LodgingMockRepository
    implements ForQueryingLodging, ForPersistingReservations {
  final LodgingMockDataSource _ds;
  static const _reservationsKey =
      'user_lodging_reservations'; // Clave de SharedPreferences

  LodgingMockRepository({LodgingMockDataSource? dataSource})
    : _ds = dataSource ?? LodgingMockDataSource();

  @override
  Future<void> saveReservation(
    DateTime initDate,
    DateTime endDate,
    Campus campus,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final authService = serviceLocator<ForAuthenticatingUser>();
    final home = await getResidenceById(campus.id);

    // Recuperar todas las reservas persistidas por el usuario
    final currentReservations = await getStudentAgendas();

    // Añadir el inicio de la reserva
    currentReservations.add(
      AgendaModel(
        id: currentReservations.isNotEmpty
            ? currentReservations.last.id + 1
            : 1,
        studentId: int.parse(authService.currentUser?.id ?? '0'),
        occupantName: authService.currentUser?.name ?? '',
        reservationDate: DateFormat('yyyy-MM-dd').format(initDate),
        clinicalName: campus.name,
        occupantMobile: '+5691111111',
        occupantKind: 'intern',
        homeId: home.homeId,
        reservationInit: '10:00',
        reservationFin: '20:00',
        state: EstadoAgenda.pendiente,
      ),
    );

    // Añadir el fin de la reserva
    currentReservations.add(
      AgendaModel(
        id: currentReservations.isNotEmpty
            ? currentReservations.last.id + 1
            : 1,
        studentId: int.parse(authService.currentUser?.id ?? '0'),
        occupantName: authService.currentUser?.name ?? '',
        reservationDate: DateFormat('yyyy-MM-dd').format(endDate),
        clinicalName: campus.name,
        occupantMobile: '+5691111111',
        occupantKind: 'intern',
        homeId: home.homeId,
        reservationInit: '10:00',
        reservationFin: '20:00',
        state: EstadoAgenda.pendiente,
      ),
    );

    // Serializar y guardar en SharedPreferences
    final jsonList = currentReservations.map((r) => r.toJson()).toList();
    final jsonString = json.encode(jsonList);

    await prefs.setString(_reservationsKey, jsonString);
  }

  @override
  Future<List<AgendaModel>> getStudentAgendas() async {
    // Reservas iniciales del JSON
    final rawFromDs = await _ds.getStudentSchedulesRaw();
    final initialReservations = rawFromDs
        .map((j) => AgendaModel.fromJson(j))
        .toList();

    // Reservas creadas por el usuario
    final prefs = await SharedPreferences.getInstance();
    final userReservationsJson = prefs.getString(_reservationsKey);
    final List<AgendaModel> userReservations = [];

    if (userReservationsJson != null) {
      final List<dynamic> userReservationsList = json.decode(
        userReservationsJson,
      );
      userReservations.addAll(
        userReservationsList.map((json) => AgendaModel.fromJson(json)).toList(),
      );
    }

    // Se agregarán las que no estén en initialReservations
    final initialIds = initialReservations.map((r) => r.id).toSet();
    final newUserReservations = userReservations
        .where((r) => !initialIds.contains(r.id))
        .toList();

    return [...initialReservations, ...newUserReservations];
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

  @override
  Future<List<Map<String, dynamic>>>
  getOccupiedReservationsForCalendar() async {
    final List<Map<String, dynamic>> occupiedReservations = [];

    // Cargar todas las reservas del mock JSON
    final allSchedules = await _ds.getSchedulesRaw();

    for (final it in allSchedules) {
      final clinicalName =
          (it['clinical_name'] as String?)?.trim() ?? 'Clínico';
      final String reservationInit = it['reservation_init'] as String;
      final String reservationFin = it['reservation_fin'] as String;

      occupiedReservations.add({
        'area': clinicalName,
        'reservationInit': reservationInit,
        'reservationFin': reservationFin,
      });
    }

    return occupiedReservations;
  }
}

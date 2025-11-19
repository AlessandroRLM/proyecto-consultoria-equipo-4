import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:mobile/adapters/lodging/driven/datasources/lodging_mock_datasource.dart';
import 'package:mobile/domain/models/lodging/agenda_model.dart';
import 'package:mobile/domain/models/lodging/estado_agenda.dart';
import 'package:mobile/adapters/core/driven/services/campus_mock_service.dart';
import 'package:mobile/domain/core/campus.dart';
import 'package:mobile/domain/models/lodging/residencia_model.dart';

class LodgingProvider with ChangeNotifier {
  final LodgingMockDataSource _ds;

  LodgingProvider({LodgingMockDataSource? dataSource})
    : _ds = dataSource ?? LodgingMockDataSource();

  final List<AgendaModel> _reservations = [];
  final List<AgendaModel> _userReservations = [];
  final List<Map<String, dynamic>> _occupiedReservations = [];
  bool _loading = false;
  String? _error;

  List<AgendaModel> get reservations => List.unmodifiable(_reservations);
  List<AgendaModel> get userReservations =>
      List.unmodifiable(_userReservations);
  List<Map<String, dynamic>> get occupiedReservations =>
      List.unmodifiable(_occupiedReservations);
  bool get loading => _loading;
  String? get error => _error;

  Campus? _selectedClinic;
  Campus? get selectedClinic => _selectedClinic;

  void selectClinic(Campus clinic) {
    _selectedClinic = clinic;
    notifyListeners();
  }

  Future<void> fetchReservations() async {
    _loading = true;
    _error = null;
    _reservations.clear();
    _userReservations.clear();
    _occupiedReservations.clear();
    notifyListeners();

    try {
      // 1) Cargar homes e indexar por homeId
      final homes = await _ds.getHomesRaw();
      final Map<int, Map<String, dynamic>> homeById = {
        for (final h in homes) (h['homeId'] as int): h,
      };

      // 2) Cargar reservas del estudiante
      final schedules = await _ds.getStudentSchedulesRaw();

      // 3) Construir items para la UI
      for (final it in schedules) {
        final int id = it['id'] as int; // viene del schedule
        final int studentId = it['student_id'] as int;
        final String occupantName = it['occupant_name'] as String;
        final String occupantMobile = it['occupant_mobile'] as String;
        final String occupantKind = it['occupant_kind'] as String;
        final String reservationDate = it['reservation_date'] as String;
        final String reservationInit = it['reservation_init'] as String;
        final String reservationFin = it['reservation_fin'] as String;
        final clinicalName = it['clinical_name'] as String;
        final int homeId = it['home_id'] as int;
        final String state = it['state'] as String;

        _reservations.add(
          AgendaModel(
            id: id,
            studentId: studentId,
            occupantName: occupantName,
            occupantMobile: occupantMobile,
            occupantKind: occupantKind,
            reservationDate: reservationDate,
            reservationInit: reservationInit,
            reservationFin: reservationFin,
            clinicalName: clinicalName,
            homeId: homeId,
            state: EstadoAgendaX.fromJson(state),
          ),
        );
      }
      // (opcional) ordenar por fecha asc
      _reservations.sort(
        (a, b) => a.reservationInit.compareTo(b.reservationInit),
      );

      // 4) Cargar todas las reservas ocupadas para el calendario
      final allSchedules = await _ds.getSchedulesRaw();
      for (final it in allSchedules) {
        final int homeId = it['home_id'] as int;
        // ignore: unused_local_variable
        final h = homeById[homeId];
        final clinicalName =
            (it['clinical_name'] as String?)?.trim() ?? 'Clínico';
        final String reservationInit = it['reservation_init'] as String;
        final String reservationFin = it['reservation_fin'] as String;
        _occupiedReservations.add({
          'area': clinicalName,
          'reservationInit': reservationInit,
          'reservationFin': reservationFin,
        });
      }

      // 5) Cargar reservas del usuario desde SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userReservationsJson = prefs.getString('user_lodging_reservations');
      if (userReservationsJson != null) {
        final List<dynamic> userReservationsList = json.decode(
          userReservationsJson,
        );
        _userReservations.addAll(
          userReservationsList
              .map((json) => AgendaModel.fromJson(json))
              .toList(),
        );
      }
    } catch (e) {
      _error = e.toString();
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> saveReservations() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(
      _reservations.map((r) => r.toJson()).toList(),
    );
    await prefs.setString('lodging_reservations', jsonString);
  }

  Future<void> saveUserReservations() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(
      _userReservations.map((r) => r.toJson()).toList(),
    );
    await prefs.setString('user_lodging_reservations', jsonString);
  }

  void addReservation(AgendaModel reservation) {
    _userReservations.add(reservation);
    saveUserReservations();
    notifyListeners();
  }

  final CampusMockService _campusService = CampusMockService();

  Future<Map<String, String>?> getClinicInfoByName(String area) async {
    try {
      final campuses = await _campusService.getCampus(null);
      final campus = campuses.firstWhere((c) => c.name == area);
      return {
        "city": campus.city,
        "commune": campus.commune,
        "address": "", // Futura address especifica
      };
    } catch (e) {
      return null;
    }
  }

  DateTime getMinReservableDate() {
    const int cutoffWeekday = 3;
    final now = DateTime.now();
    final todayWeekday = now.weekday;
    final daysToNextMonday = (DateTime.monday - todayWeekday + 7) % 7;
    final nextMonday = now.add(
      Duration(days: daysToNextMonday == 0 ? 7 : daysToNextMonday),
    );
    DateTime minReservableDate;
    if (todayWeekday < cutoffWeekday) {
      minReservableDate = nextMonday;
    } else {
      minReservableDate = nextMonday.add(const Duration(days: 7));
    }
    return minReservableDate;
  }

  Future<ResidenciaModel> fetchResidenceDetail(int homeId) async {
    // Cargamos todas las residencias desde el datasource mock
    final homes = await _ds.getHomesRaw();

    // Buscamos la residencia con ese homeId
    final homeJson = homes.firstWhere(
      (h) => (h['homeId'] as int) == homeId,
      orElse: () =>
          throw Exception('Residencia no encontrada para homeId $homeId'),
    );

    // Convertimos el JSON al modelo de dominio
    return ResidenciaModel.fromJson(homeJson);
  }
}

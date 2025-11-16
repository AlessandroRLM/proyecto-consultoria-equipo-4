import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:mobile/adapters/lodging/driven/datasources/lodging_mock_datasource.dart';

// === Modelos existentes (rama main) ===
import 'package:mobile/domain/models/lodging/agenda_model.dart';
import 'package:mobile/domain/models/lodging/estado_agenda.dart';
import 'package:mobile/adapters/core/driven/campus_mock_service.dart';
import 'package:mobile/domain/core/campus.dart';

// === Modelos agregados para detalle_residencia ===
import 'package:mobile/domain/models/lodging/lodging_reservation_model.dart';
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
  List<AgendaModel> get userReservations => List.unmodifiable(_userReservations);
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

  // ==========================================================
  // 🔹 Cargar reservas (agenda + homes)
  // ==========================================================
  Future<void> fetchReservations() async {
    _loading = true;
    _error = null;

    _reservations.clear();
    _userReservations.clear();
    _occupiedReservations.clear();
    notifyListeners();

    try {
      // 1) Cargar lista completa de residencias
      final homes = await _ds.getHomesRaw();
      final Map<int, Map<String, dynamic>> homeById = {
        for (final h in homes) (h['homeId'] as int): h,
      };

      // 2) Cargar reservas del estudiante
      final schedules = await _ds.getStudentSchedulesRaw();

      // 3) Construir modelos para UI
      for (final it in schedules) {
        final int id = it['id'] as int;
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

      // Ordenar por inicio
      _reservations.sort(
        (a, b) => a.reservationInit.compareTo(b.reservationInit),
      );

      // 4) Cargar TODAS las reservas ocupadas
      final allSchedules = await _ds.getSchedulesRaw();

      for (final it in allSchedules) {
        _occupiedReservations.add({
          'area': (it['clinical_name'] as String?) ?? 'Clínico',
          'reservationInit': it['reservation_init'] as String,
          'reservationFin': it['reservation_fin'] as String,
        });
      }

      // 5) Cargar reservas guardadas del usuario
      final prefs = await SharedPreferences.getInstance();
      final userResJson = prefs.getString('user_lodging_reservations');

      if (userResJson != null) {
        final list = json.decode(userResJson);
        _userReservations.addAll(
          list.map<AgendaModel>((json) => AgendaModel.fromJson(json)).toList(),
        );
      }
    } catch (e) {
      _error = e.toString();
    }

    _loading = false;
    notifyListeners();
  }

  // ==========================================================
  // 🔹 Obtener DETALLE COMPLETO de una residencia (home.json)
  // ==========================================================
  Future<ResidenciaModel> fetchResidenceDetail(int homeId) async {
    try {
      final homes = await _ds.getHomesRaw();

      final json = homes.firstWhere(
        (h) => h['homeId'] == homeId,
        orElse: () => throw Exception('Residencia no encontrada'),
      );

      return ResidenciaModel.fromJson(json);
    } catch (e) {
      throw Exception('Error al cargar detalle de residencia: $e');
    }
  }

  // ==========================================================
  // 🔹 Guardado local
  // ==========================================================
  Future<void> saveReservations() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString =
        json.encode(_reservations.map((r) => r.toJson()).toList());
    await prefs.setString('lodging_reservations', jsonString);
  }

  Future<void> saveUserReservations() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString =
        json.encode(_userReservations.map((r) => r.toJson()).toList());
    await prefs.setString('user_lodging_reservations', jsonString);
  }

  void addReservation(AgendaModel reservation) {
    _userReservations.add(reservation);
    saveUserReservations();
    notifyListeners();
  }

  // ==========================================================
  // 🔹 Información de clínica relacionada
  // ==========================================================
  final CampusMockService _campusService = CampusMockService();

  Future<Map<String, String>?> getClinicInfoByName(String area) async {
    try {
      final campuses = await _campusService.getCampus(null);
      final campus = campuses.firstWhere((c) => c.name == area);

      return {
        "city": campus.city,
        "commune": campus.commune,
        "address": "",
      };
    } catch (_) {
      return null;
    }
  }

  // ==========================================================
  // 🔹 Calcular fecha mínima reservable
  // ==========================================================
  DateTime getMinReservableDate() {
    const cutoffWeekday = 3;
    final now = DateTime.now();
    final today = now.weekday;
    final daysToNextMon = (DateTime.monday - today + 7) % 7;

    final nextMonday =
        now.add(Duration(days: daysToNextMon == 0 ? 7 : daysToNextMon));

    if (today < cutoffWeekday) {
      return nextMonday;
    } else {
      return nextMonday.add(const Duration(days: 7));
    }
  }
}

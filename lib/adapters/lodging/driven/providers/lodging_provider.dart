import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:mobile/adapters/lodging/driven/datasources/lodging_mock_datasource.dart';
import 'package:mobile/domain/models/lodging/lodging_reservation_model.dart';
import 'package:mobile/adapters/core/driven/campus_mock_service.dart';
import 'package:mobile/domain/core/campus.dart';

class LodgingProvider with ChangeNotifier {
  final LodgingMockDataSource _ds;

  LodgingProvider({LodgingMockDataSource? dataSource})
    : _ds = dataSource ?? LodgingMockDataSource();

  final List<LodgingReservation> _reservations = [];
  final List<LodgingReservation> _userReservations = [];
  final List<Map<String, dynamic>> _occupiedReservations = [];
  bool _loading = false;
  String? _error;

  List<LodgingReservation> get reservations => List.unmodifiable(_reservations);
  List<LodgingReservation> get userReservations => List.unmodifiable(_userReservations);
  List<Map<String, dynamic>> get occupiedReservations => List.unmodifiable(_occupiedReservations);
  bool get loading => _loading;
  String? get error => _error;

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
        final int homeId = it['home_id'] as int; // viene del schedule
        final h = homeById[homeId]; // buscamos la residencia

        final clinicalName =
            (it['clinical_name'] as String?)?.trim() ?? 'Clínico';
        final residenceName = (h?['residenceName'] as String?) ?? 'Residencia';
        final address = (h?['address'] as String?) ?? 'Dirección no disponible';

        final dateStr = (it['reservation_date'] as String?) ?? '2025-09-08';
        final checkIn = dateStr; 
        final checkOut = dateStr; 

        //  HABITACIÓN: usa el home_id como número (sin letras).
        final room = homeId.toString(); // ej. "101"
        _reservations.add(
          LodgingReservation(
            area: clinicalName,
            name: residenceName,
            address: address,
            room: room, // ahora "101" (número, sin prefijos)
            checkIn: checkIn,
            checkOut: checkOut,
          ),
        );
      }
      // (opcional) ordenar por fecha asc
      _reservations.sort((a, b) => a.checkIn.compareTo(b.checkIn));

      // 4) Cargar todas las reservas ocupadas para el calendario
      final allSchedules = await _ds.getSchedulesRaw();
      for (final it in allSchedules) {
        final int homeId = it['home_id'] as int;
        final h = homeById[homeId];
        final clinicalName = (it['clinical_name'] as String?)?.trim() ?? 'Clínico';
        final dateStr = (it['reservation_date'] as String?) ?? '2025-09-08';
        _occupiedReservations.add({
          'area': clinicalName,
          'checkIn': dateStr,
          'checkOut': dateStr,
        });
      }

      // 5) Cargar reservas del usuario desde SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userReservationsJson = prefs.getString('user_lodging_reservations');
      if (userReservationsJson != null) {
        final List<dynamic> userReservationsList = json.decode(userReservationsJson);
        _userReservations.addAll(
          userReservationsList.map((json) => LodgingReservation.fromJson(json)).toList(),
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
    final jsonString = json.encode(_reservations.map((r) => r.toJson()).toList());
    await prefs.setString('lodging_reservations', jsonString);
  }

  Future<void> saveUserReservations() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(_userReservations.map((r) => r.toJson()).toList());
    await prefs.setString('user_lodging_reservations', jsonString);
  }

  void addReservation(LodgingReservation reservation) {
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
    final nextMonday = now.add(Duration(days: daysToNextMonday == 0 ? 7 : daysToNextMonday));
    DateTime minReservableDate;
    if (todayWeekday < cutoffWeekday) {
      minReservableDate = nextMonday;
    } else {
      minReservableDate = nextMonday.add(const Duration(days: 7));
    }
    return minReservableDate;
  }
}

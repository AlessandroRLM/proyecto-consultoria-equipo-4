import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:mobile/adapters/lodging/driven/datasources/lodging_mock_datasource.dart';
import 'package:mobile/domain/models/lodging/lodging_reservation_model.dart';

class LodgingProvider with ChangeNotifier {
  final LodgingMockDataSource _ds;

  LodgingProvider({LodgingMockDataSource? dataSource})
    : _ds = dataSource ?? LodgingMockDataSource();

  final List<LodgingReservation> _reservations = [];
  bool _loading = false;
  String? _error;

  List<LodgingReservation> get reservations => List.unmodifiable(_reservations);
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchReservations() async {
    _loading = true;
    _error = null;
    _reservations.clear();
    notifyListeners();

    try {
      // 1) Cargar homes e indexar por homeId
      final homes = await _ds.getHomesRaw();
      final Map<int, Map<String, dynamic>> homeById = {
        for (final h in homes) (h['homeId'] as int): h,
      };

      // 2) Cargar reservas del estudiante
      final schedules = await _ds.getStudentSchedulesRaw();

      // --- helpers de presentación --- //
      String fmtDay(String ymd) {
        final d = DateTime.parse(ymd);
        const days = ['LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB', 'DOM'];
        final dow = days[(d.weekday - 1) % 7];
        final dd = d.day.toString().padLeft(2, '0');
        final mm = d.month.toString().padLeft(2, '0');
        return '$dow $dd/$mm';
      }
      // -------------------------------- //

      // 3) Construir items para la UI
      for (final it in schedules) {
        final int homeId = it['home_id'] as int; // viene del schedule
        final h = homeById[homeId]; // buscamos la residencia

        final clinicalName =
            (it['clinical_name'] as String?)?.trim() ?? 'Clínico';
        final residenceName = (h?['residenceName'] as String?) ?? 'Residencia';
        final address = (h?['address'] as String?) ?? 'Dirección no disponible';

        final dateStr = (it['reservation_date'] as String?) ?? '2025-09-08';
        final checkIn = fmtDay(dateStr);
        final checkOut = fmtDay(dateStr); // mismo día

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

  void addReservation(LodgingReservation reservation) {
    _reservations.add(reservation);
    saveReservations();
    notifyListeners();
  }

  final List<Map<String, String>> clinics = [
    {
      "name": "Centro Médico Andes Salud Talca",
      "city": "Talca",
      "address": "Cuatro Nte. 1656, 3467384 Talca, Maule",
    },
    {
      "name": "Clínica Santa María",
      "city": "Talca",
      "address": "Calle Falsa 123, Talca, Maule",
    },
  ];
  
  Map<String, String>? getClinicInfoByName(String area) {
    try {
      return clinics.firstWhere((clinic) => clinic["name"] == area);
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

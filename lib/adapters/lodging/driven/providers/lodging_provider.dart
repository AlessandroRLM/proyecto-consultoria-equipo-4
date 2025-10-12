import 'package:flutter/material.dart';
import 'package:mobile/adapters/lodging/driven/datasources/lodging_mock_datasource.dart';
import 'package:mobile/domain/models/lodging/lodging_reservation_model.dart';
import 'package:mobile/domain/models/lodging/residencia_model.dart';

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
            homeId: homeId,
            area: clinicalName,
            name: residenceName,
            address: address,
            room: room,
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

  // ==========================================================
  // 🔹 Obtener detalle completo de una residencia (home.json)
  // ==========================================================
  Future<ResidenciaModel> fetchResidenceDetail(int homeId) async {
    try {
      // Cargar lista completa de residencias desde el mock
      final homes = await _ds.getHomesRaw();

      // Buscar por homeId (igual que en home.json)
      final json = homes.firstWhere(
        (h) => h['homeId'] == homeId,
        orElse: () => throw Exception('Residencia no encontrada'),
      );

      // Convertir el JSON a tu modelo ResidenciaModel
      return ResidenciaModel.fromJson(json);
    } catch (e) {
      throw Exception('Error al cargar detalle de residencia: $e');
    }
  }
}

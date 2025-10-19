import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:mobile/adapters/lodging/driven/datasources/lodging_mock_datasource.dart';
import 'package:mobile/domain/models/lodging/lodging_reservation_model.dart';
import 'package:mobile/adapters/core/driven/campus_mock_service.dart';
import 'package:mobile/domain/models/lodging/agenda_model.dart';
import 'package:mobile/domain/models/lodging/residencia_model.dart';

class LodgingProvider with ChangeNotifier {
  final LodgingMockDataSource _ds;
  LodgingProvider({LodgingMockDataSource? dataSource})
    : _ds = dataSource ?? LodgingMockDataSource();

  final List<AgendaModel> _agendas = [];
  Map<int, ResidenciaModel> _homeById = {};
  bool _loading = false;
  String? _error;

  List<AgendaModel> get agendas => List.unmodifiable(_agendas);
  bool get loading => _loading;
  String? get error => _error;

  ResidenciaModel? getHomeById(int id) => _homeById[id];

  /// Carga agendas (del estudiante)
  Future<void> fetchAgendas() async {
    _loading = true;
    _error = null;
    _agendas.clear();
    notifyListeners();

    try {
      // 1) Residencias
      final homesRaw = await _ds.getHomesRaw();
      // 2) Agendas del estudiante
      _agendas.addAll(schedulesRaw.map((e) => AgendaModel.fromJson(e)));

      // Orden por fecha, depende de tu AgendaModel
      _agendas.sort((a, b) {
        final da = DateTime.tryParse(a.reservationDate ?? '') ?? DateTime(1970);
        final db = DateTime.tryParse(b.reservationDate ?? '') ?? DateTime(1970);
        return da.compareTo(db);
      });
    } catch (e) {
      _error = e.toString();
    }

    _loading = false;
    notifyListeners();
  }

<<<<<<< HEAD
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
=======
  /// Detalle de residencia para la pantalla de detalle
  Future<ResidenciaModel> fetchResidenceDetail(int homeId) async {
    final cached = _homeById[homeId];
    if (cached != null) return cached;

    final homesRaw = await _ds.getHomesRaw();
    final json = homesRaw.firstWhere(
      (h) => h['homeId'] == homeId,
      orElse: () => throw Exception('Residencia no encontrada'),
    );
    final model = ResidenciaModel.fromJson(json);
    _homeById[homeId] = model;
    return model;

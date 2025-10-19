import 'package:flutter/material.dart';
import 'package:mobile/adapters/lodging/driven/datasources/lodging_mock_datasource.dart';
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
      _homeById = {
        for (final h in homesRaw)
          (h['homeId'] as int): ResidenciaModel.fromJson(h),
      };

      // 2) Agendas del estudiante
      final schedulesRaw = await _ds.getStudentSchedulesRaw();
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
  }
}

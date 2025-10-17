import 'package:flutter/material.dart';
import 'package:mobile/adapters/lodging/driven/datasources/lodging_mock_datasource.dart';
import 'package:mobile/domain/models/lodging/clinic_availability_model.dart';
import 'package:mobile/domain/models/lodging/residencia_model.dart';
import 'package:mobile/domain/models/lodging/agenda_model.dart';
import 'package:mobile/domain/models/lodging/estado_agenda.dart';

class LodgingAvailabilityProvider with ChangeNotifier {
  final LodgingMockDataSource _ds;
  LodgingAvailabilityProvider({LodgingMockDataSource? dataSource})
    : _ds = dataSource ?? LodgingMockDataSource();

  bool _loading = false;
  String? _error;
  final List<ClinicAvailabilityItem> _items = [];

  bool get loading => _loading;
  String? get error => _error;
  List<ClinicAvailabilityItem> get items => List.unmodifiable(_items);

  Future<void> fetchAvailability({DateTime? date}) async {
    if (_loading) return; 
    _loading = true;
    _error = null;
    _items.clear();
    notifyListeners();

    try {
      // 1) Cargar fuentes
      final homesRaw = await _ds.getHomesRaw();
      final allSchedRaw = await _ds.getSchedulesRaw(); // schedule.json

      // 2) Mapear a modelos de dominio (tolerantes a int/string)
      final homes = homesRaw.map((e) => ResidenciaModel.fromJson(e)).toList();
      final agendas = allSchedRaw.map((e) => AgendaModel.fromJson(e)).toList();

      // 3) Excluir FINALIZADAS
      final activas = agendas.where((a) => a.state != EstadoAgenda.finalizada);

      // 4) Fecha consultada (hoy por defecto) en formato YYYY-MM-DD
      final d = date ?? DateTime.now();
      final target =
          '${d.year.toString().padLeft(4, '0')}-'
          '${d.month.toString().padLeft(2, '0')}-'
          '${d.day.toString().padLeft(2, '0')}';

      // 5) Ocupación por homeId SOLO para esa fecha
      final Map<int, int> ocupadas = {};
      for (final a in activas) {
        if (a.reservationDate != target) continue;
        ocupadas.update(a.homeId, (v) => v + 1, ifAbsent: () => 1);
      }

      // 6) Construir ítems visibles: solo homes con disponibilidad
      for (final h in homes) {
        final usadas = ocupadas[h.homeId] ?? 0;
        final disponibles = h.bedCount - usadas;
        if (disponibles <= 0) continue;

        final city = _extractCity(h.address);
        for (final cf in h.clinicalFields) {
          _items.add(
            ClinicAvailabilityItem(
              clinicName: cf.clinicalFieldName,
              residenceName: h.residenceName,
              city: city,
              address: h.address,
            ),
          );
        }
      }

      // Orden opcional
      _items.sort((a, b) => a.clinicName.compareTo(b.clinicName));
    } catch (e) {
      _error = e.toString();
    }

    _loading = false;
    notifyListeners();
  }

  String _extractCity(String address) {
    final parts = address.split(',').map((e) => e.trim()).toList();
    if (parts.length >= 2) return parts[1];
    if (parts.isNotEmpty) {
      final tokens = parts.first.split(' ').where((t) => t.isNotEmpty).toList();
      if (tokens.isNotEmpty) return tokens.last;
    }
    return '';
  }
}

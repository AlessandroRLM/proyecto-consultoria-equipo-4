import 'package:flutter/material.dart';
import 'package:mobile/domain/models/lodging/agenda_model.dart';
import 'package:mobile/ports/lodging/driven/for_querying_lodging.dart';

class LodgingProvider extends ChangeNotifier {
  final ForQueryingLodging _lodgingService;
  
  List<AgendaModel> _reservations = [];
  bool _isLoading = false;
  String? _error;

  List<AgendaModel> get reservations => _reservations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  LodgingProvider(this._lodgingService) {
    loadReservations();
  }

  Future<void> loadReservations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reservations = await _lodgingService.getStudentAgendas();
      _error = null;
    } catch (e) {
      _error = 'Ocurrió un error al cargar las reservas.';
      _reservations = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadReservations();
  }
}
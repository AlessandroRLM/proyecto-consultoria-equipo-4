import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/adapters/transport/driven/providers/reservations/reservations.dart';
import 'package:mobile/domain/entities/transport_reservation_status.dart';
import 'package:mobile/domain/models/transport/agenda_model.dart';
import 'package:mobile/domain/models/transport/service_model.dart';
import 'package:mobile/ports/transport/driven/for_querying_transport.dart';

class TransportReservationsProvider extends ChangeNotifier {
  TransportReservationsProvider({required this.repo});

  final ForQueryingTransport repo;

  final TransportReservationStore _reservationStore =
      TransportReservationStore();
  final TransportServiceOptionsCache _optionsCache =
      TransportServiceOptionsCache();
  final TransportTimeUtils _timeUtils = const TransportTimeUtils();
  late final TransportReservationBuilder _reservationBuilder =
      TransportReservationBuilder(timeUtils: _timeUtils);
  final TransportSelectionState _selection = TransportSelectionState();
  final TransportWeekConstraints _weekConstraints =
      const TransportWeekConstraints();
  final TransportAgendaMapper _agendaMapper = const TransportAgendaMapper();

  List<TransportAgendaModel> _loadedAgenda = const [];
  List<TransportServiceModel> _loadedServices = const [];
  Object? _lastError;

  List<TransportAgendaModel> get loadedAgenda => _loadedAgenda;
  List<TransportServiceModel> get loadedServices => _loadedServices;
  Object? get lastError => _lastError;

  List<Map<String, dynamic>> get reservations =>
      _reservationStore.reservations;
  List<Map<String, dynamic>> get futureReservations =>
      _reservationStore.futureReservations();
  Map<String, Map<bool, List<Map<String, dynamic>>>> get optionsByDate =>
      _optionsCache.optionsByDate;

  String? get nextAvailableDate {
    final candidate = _optionsCache.findNextAvailableDate(
      services: _loadedServices,
      selectedLocation: _selection.location,
    );
    if (candidate == null) {
      return null;
    }
    return DateFormat('EEE dd/MM', 'es_ES').format(candidate);
  }

  Future<void> loadStudentAgenda(TransportAgendaQuery query) async {
    try {
      final agenda = await repo.getStudentAgenda(query);
      _loadedAgenda = agenda;
      _syncReservationsFromAgenda(force: true);
      notifyListeners();
    } catch (error) {
      _lastError = error;
      notifyListeners();
    }
  }

  Future<void> loadServices(TransportServiceQuery query) async {
    try {
      final services = await repo.getServices(query);
      _loadedServices = services;
      _optionsCache.clear();
      notifyListeners();
    } catch (error) {
      _lastError = error;
      notifyListeners();
    }
  }

  Future<void> createReservationForService({
    required TransportServiceModel service,
    required DateTime date,
  }) async {
    try {
      final agenda = await repo.createReservation(
        serviceId: service.id,
        date: date,
      );
      _loadedAgenda = [
        ..._loadedAgenda.where((a) => a.agendaId != agenda.agendaId),
        agenda,
      ];
      _syncReservationsFromAgenda(force: true);
      notifyListeners();
    } catch (error) {
      _lastError = error;
      notifyListeners();
    }
  }

  Future<void> cancelReservationById(int agendaId) async {
    try {
      await repo.cancelReservation(agendaId);
      _loadedAgenda =
          _loadedAgenda.where((a) => a.agendaId != agendaId).toList();
      _syncReservationsFromAgenda(force: true);
      notifyListeners();
    } catch (error) {
      _lastError = error;
      notifyListeners();
    }
  }

  Future<void> fetchReservations() async {
    await _reservationStore.load(
      statusResolver: TransportReservationStatusHelper.resolve,
    );
    notifyListeners();
  }

  Future<void> saveReservations() {
    return _reservationStore.persist();
  }

  bool isValidRange(DateTime start, DateTime end) =>
      _weekConstraints.isValidRange(start, end);

  List<Map<String, dynamic>> getAvailableOptionsForDate(
    String dateStr, {
    bool isOutbound = true,
  }) {
    return _optionsCache.getAvailableOptionsForDate(
      dateStr: dateStr,
      isOutbound: isOutbound,
      services: _loadedServices,
      selectedLocation: _selection.location,
    );
  }

  bool isWeekAllowed(DateTime date) => _weekConstraints.isWeekAllowed(date);

  List<Map<String, dynamic>> getOptionsForDate(
    String dateStr, {
    bool isOutbound = true,
  }) {
    return _optionsCache.getOptionsForDate(
      dateStr: dateStr,
      isOutbound: isOutbound,
      services: _loadedServices,
      selectedLocation: _selection.location,
    );
  }

  bool hasAvailableOptions(String dateStr) {
    return _optionsCache.hasAvailableOptions(
      dateStr: dateStr,
      services: _loadedServices,
      selectedLocation: _selection.location,
    );
  }

  void updateReservations(List<Map<String, dynamic>> newReservations) async {
    _reservationStore.replace(newReservations);
    await _persistAndNotify();
  }

  void sortReservations() {
    _reservationStore.sort();
  }

  void addReservation(Map<String, dynamic> reservation) async {
    final dateValue = reservation['date'];
    if (dateValue == null) {
      reservation['date'] = DateFormat('yyyy-MM-dd').format(DateTime.now());
    } else if (dateValue is DateTime) {
      reservation['date'] = DateFormat('yyyy-MM-dd').format(dateValue);
    }
    reservation['service'] ??= 'Transporte';
    reservation['details'] ??= '';
    reservation['status'] ??=
        TransportReservationStatus.pendiente.displayName;
    _reservationStore.addReservation(reservation);
    await _persistAndNotify();
  }

  void addWeekReservation(
    Map<String, dynamic> baseReservation,
    DateTime startDate, {
    int daysToAdd = 30,
  }) async {
    baseReservation['status'] ??=
        TransportReservationStatus.pendiente.displayName;
    final endDate = startDate.add(Duration(days: daysToAdd));
    if (!isValidRange(startDate, endDate)) {
      return;
    }
    final List<Map<String, dynamic>> createdReservations = [];
    for (int i = 0; i <= daysToAdd; i++) {
      final date = startDate.add(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      if (hasAvailableOptions(dateStr)) {
        final reservation = Map<String, dynamic>.from(baseReservation);
        reservation['date'] = dateStr;
        createdReservations.add(reservation);
      }
    }
    if (createdReservations.isEmpty) {
      return;
    }
    _reservationStore.addReservations(createdReservations);
    await _persistAndNotify();
  }

  Map<String, String>? get selectedLocation => _selection.location;
  set selectedLocation(Map<String, String>? value) {
    _selection.location = value;
    _optionsCache.clear();
    notifyListeners();
  }

  String? get selectedOutboundTime => _selection.outboundTime;
  set selectedOutboundTime(String? value) {
    _selection.outboundTime = value;
    notifyListeners();
  }

  String? get selectedReturnTime => _selection.returnTime;
  set selectedReturnTime(String? value) {
    _selection.returnTime = value;
    notifyListeners();
  }

  String? get selectedDate => _selection.outboundDate;
  set selectedDate(dynamic value) {
    _selection.setOutboundDate(value);
    notifyListeners();
  }

  String? get selectedReturnDate => _selection.returnDate;
  set selectedReturnDate(dynamic value) {
    _selection.setReturnDate(value);
    notifyListeners();
  }

  String? get selectedService => _selection.service;
  set selectedService(String? value) {
    _selection.service = value;
    notifyListeners();
  }

  void addOutboundReservation() async {
    final selection = _selection.outboundSelection();
    if (selection == null) {
      return;
    }
    final reservation = _reservationBuilder.buildOutboundReservation(
      date: selection.date,
      location: selection.location,
      time: selection.time,
      service: selection.service,
    );
    _reservationStore.addReservation(reservation);
    await _persistAndNotify();
  }

  void addReturnReservation() async {
    final selection = _selection.returnSelection();
    if (selection == null) {
      return;
    }
    final reservation = _reservationBuilder.buildReturnReservation(
      date: selection.date,
      location: selection.location,
      time: selection.time,
      service: selection.service,
    );
    _reservationStore.addReservation(reservation);
    await _persistAndNotify();
    _selection.clearReturnSelection();
  }

  void addRoundTripReservation() async {
    final selection = _selection.roundTripSelection();
    if (selection == null) {
      return;
    }
    final reservation = _reservationBuilder.buildRoundTripReservation(
      location: selection.location,
      outboundDate: selection.outboundDate,
      returnDate: selection.returnDate,
      outboundTime: selection.outboundTime,
      returnTime: selection.returnTime,
      service: selection.service,
    );
    _reservationStore.addReservation(reservation);
    await _persistAndNotify();
    _selection.clearAll();
  }

  bool hasOutboundOnDate(String date) {
    return _reservationStore.hasOutboundOnDate(date);
  }

  bool hasReturnOnDate(String date) {
    return _reservationStore.hasReturnOnDate(date);
  }

  bool isOptionReserved(
    String date,
    String time, {
    bool isOutbound = true,
  }) {
    final formattedTime = _reservationBuilder.normalizeTime(time);
    return _reservationStore.isLegReserved(
      date: date,
      formattedTime: formattedTime,
      isOutbound: isOutbound,
    );
  }

  Future<bool> reserveLeg({
    required String date,
    required String time,
    required bool isOutbound,
    String? service,
  }) async {
    try {
      final leg = _reservationBuilder.buildFlexibleLeg(
        isOutbound: isOutbound,
        date: date,
        location: _selection.location,
        time: time,
        service: service ?? _selection.service,
      );
      _reservationStore.attachLeg(leg, isOutbound: isOutbound);
      await _persistAndNotify();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> cancelLeg({
    required String date,
    required String time,
    required bool isOutbound,
  }) async {
    try {
      final formatted = _reservationBuilder.normalizeTime(time);
      final result = _reservationStore.cancelLeg(
        date: date,
        formattedTime: formatted,
        isOutbound: isOutbound,
      );
      if (!result) {
        return false;
      }
      await _persistAndNotify();
      return true;
    } catch (_) {
      return false;
    }
  }

  DateTime getMinReservableDate() =>
      _weekConstraints.getMinReservableDate();

  Future<void> fetchUpdatedReservations() async {
    await fetchReservations();
  }

  void _syncReservationsFromAgenda({bool force = false}) {
    if (!force && _loadedAgenda.isEmpty) return;
    final mapped = _agendaMapper.mapAgendaToReservations(_loadedAgenda);
    _reservationStore.replace(mapped);
  }

  Future<void> _persistAndNotify() async {
    await saveReservations();
    notifyListeners();
  }
}

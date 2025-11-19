import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/ports/transport/driven/transport_reservations_management.dart';

class TransportReservationsProvider extends ChangeNotifier {
  final TransportReservationsManagement _transportService;
  List<Map<String, dynamic>> _reservations = [];
  Map<String, String>? _selectedLocation;
  String? _selectedOutboundTime;
  String? _selectedReturnTime;
  String? _selectedDate;
  String? _selectedReturnDate;
  String? _selectedService;
  bool _isLoading = false;
  TransportReservationsProvider(this._transportService);

  List<Map<String, dynamic>> get reservations => _reservations;

  bool get isLoading => _isLoading;
  Map<String, String>? get selectedLocation => _selectedLocation;
  String? get selectedOutboundTime => _selectedOutboundTime;
  String? get selectedReturnTime => _selectedReturnTime;
  String? get selectedDate => _selectedDate;
  String? get selectedReturnDate => _selectedReturnDate;
  String? get selectedService => _selectedService;

  List<Map<String, dynamic>> get futureReservations {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    List<Map<String, dynamic>> allLegs = [];
    for (var reservation in _reservations) {
      if (reservation['outbound'] != null) {
        allLegs.add(reservation['outbound']);
      }
      if (reservation['return'] != null) {
        allLegs.add(reservation['return']);
      }
    }

    var futureRes = allLegs.where((r) {
      if (r['date'] == null) return false;
      dynamic dateValue = r['date'];
      DateTime date;
      if (dateValue is DateTime) {
        date = dateValue;
      } else {
        final dateStr = dateValue as String;
        date = DateTime.parse(dateStr);
      }
      final resDate = DateTime(date.year, date.month, date.day);
      return !resDate.isBefore(today);
    }).toList();

    futureRes.sort((a, b) {
      dynamic dateValueA = a['date'];
      dynamic dateValueB = b['date'];
      if (dateValueA == null || dateValueB == null) return 0;
      DateTime dateA;
      if (dateValueA is DateTime) {
        dateA = dateValueA;
      } else {
        dateA = DateTime.parse(dateValueA as String);
      }
      DateTime dateB;
      if (dateValueB is DateTime) {
        dateB = dateValueB;
      } else {
        dateB = DateTime.parse(dateValueB as String);
      }
      final resDateA = DateTime(dateA.year, dateA.month, dateA.day);
      final resDateB = DateTime(dateB.year, dateB.month, dateB.day);
      int dateCompare = resDateA.compareTo(resDateB);
      if (dateCompare != 0) return dateCompare;
      final detailsA = (a['details'] as String?)?.toLowerCase() ?? '';
      final detailsB = (b['details'] as String?)?.toLowerCase() ?? '';
      if (detailsA.contains('ida') && detailsB.contains('regreso')) {
        return -1;
      } else if (detailsA.contains('regreso') && detailsB.contains('ida')) {
        return 1;
      }
      return 0;
    });
    return futureRes;
  }

  String? get nextAvailableDate => _transportService.getNextAvailableDate();

  Future<void> loadReservations() async {
    _isLoading = true;
    notifyListeners();
    try {
      _reservations = await _transportService.fetchReservations();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchReservations() => loadReservations();

  Future<void> saveReservations() async {
    await _transportService.saveReservations(_reservations);
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> getAvailableSchedules(
    String date,
    bool isOutbound,
  ) async {
    return await _transportService.getAvailableSchedules(date, isOutbound);
  }

  Future<List<DateTime>> getReservableDates(
    String clinicalId,
    DateTime startDate,
  ) async {
    return await _transportService.getReservableDates(clinicalId, startDate, 30);
  }

  Future<void> refreshReservations() async {
    _isLoading = true;
    notifyListeners();
    try {
      _reservations = await _transportService.fetchUpdatedReservations(_reservations);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUpdatedReservations() => refreshReservations();
  
  Future<bool> reserveLeg({
    required String date,
    required String time,
    required bool isOutbound,
    String? service,
  }) async {
    final success = await _transportService.reserveLeg(
      date: date,
      time: time,
      isOutbound: isOutbound,
      service: service,
      clinicalAddress: _selectedLocation?['address'],
      clinicalName: _selectedLocation?['name'],
    );

    if (success) {
      _reservations = await _transportService.fetchReservations();
      notifyListeners();
    }

    return success;
  }

  Future<bool> cancelLeg({
    required String date,
    required String time,
    required bool isOutbound,
  }) async {
    final success = await _transportService.cancelLeg(
      date: date,
      time: time,
      isOutbound: isOutbound,
    );

    if (success) {
      _reservations = await _transportService.fetchReservations();
      notifyListeners();
    }

    return success;
  }
  bool hasOutboundOnDate(String date) => _transportService.hasOutboundOnDate(date);
  bool hasReturnOnDate(String date) => _transportService.hasReturnOnDate(date);
  bool isOptionReserved(String date, String time, {bool isOutbound = true}) {
    return _transportService.isOptionReserved(date, time, isOutbound: isOutbound);
  }

  List<Map<String, dynamic>> getOptionsForDate(
    String dateStr, {
    bool isOutbound = true,
  }) {
    return _transportService.getOptionsForDate(dateStr, isOutbound: isOutbound);
  }

  List<Map<String, dynamic>> getAvailableOptionsForDate(
    String dateStr, {
    bool isOutbound = true,
  }) {
    return _transportService.getAvailableOptionsForDate(dateStr, isOutbound: isOutbound);
  }

  bool hasAvailableOptions(String dateStr) {
    return _transportService.hasAvailableOptions(dateStr);
  }

  bool isValidRange(DateTime start, DateTime end) {
    return _transportService.isValidRange(start, end);
  }

  bool isWeekAllowed(DateTime date) {
    return _transportService.isWeekAllowed(date);
  }

  DateTime getMinReservableDate() {
    return _transportService.getMinReservableDate();
  }

  set selectedLocation(Map<String, String>? value) {
    _selectedLocation = value;
    notifyListeners();
  }

  set selectedOutboundTime(String? value) {
    _selectedOutboundTime = value;
    notifyListeners();
  }

  set selectedReturnTime(String? value) {
    _selectedReturnTime = value;
    notifyListeners();
  }

  set selectedDate(dynamic value) {
    if (value is DateTime) {
      _selectedDate = DateFormat('yyyy-MM-dd').format(value);
    } else {
      _selectedDate = value as String?;
    }
    notifyListeners();
  }

  set selectedReturnDate(dynamic value) {
    if (value is DateTime) {
      _selectedReturnDate = DateFormat('yyyy-MM-dd').format(value);
    } else {
      _selectedReturnDate = value as String?;
    }
    notifyListeners();
  }

  set selectedService(String? value) {
    _selectedService = value;
    notifyListeners();
  }

  void clearSelections() {
    _selectedLocation = null;
    _selectedOutboundTime = null;
    _selectedReturnTime = null;
    _selectedDate = null;
    _selectedReturnDate = null;
    _selectedService = null;
    notifyListeners();
  }
}

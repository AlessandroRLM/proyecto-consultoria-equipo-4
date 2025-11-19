import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:mobile/domain/entities/transport_reservation_status.dart';
import 'package:mobile/ports/transport/driven/transport_reservations_management.dart';

class TransportMockService implements TransportReservationsManagement {
  final SharedPreferences _sharedPreferences;
  
  late List<Map<String, dynamic>> _reservations;
  final Map<String, Map<bool, List<Map<String, dynamic>>>> _optionsByDate = {};
  bool _isInitialized = false;

  TransportMockService(this._sharedPreferences);

  Future<void> _initialize() async {
    if (_isInitialized) return;
    final jsonString = _sharedPreferences.getString('transport_reservations');
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      _reservations = jsonList.map((json) => Map<String, dynamic>.from(json)).toList();
      for (var reservation in _reservations) {
        if (reservation['outbound'] != null) {
          reservation['outbound']['status'] = _getStatusForReservation(reservation['outbound']);
        }
        if (reservation['return'] != null) {
          reservation['return']['status'] = _getStatusForReservation(reservation['return']);
        }
      }
    } else {
      _reservations = [];
    }
    _isInitialized = true;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchReservations() async {
    await _initialize();
    return List.from(_reservations);
  }

  @override
  Future<void> saveReservations(List<Map<String, dynamic>> reservations) async {
    await _initialize();
    _reservations = List.from(reservations);
    
    final jsonString = json.encode(
      _reservations.map((r) => Map<String, dynamic>.from(r)).toList()
    );
    await _sharedPreferences.setString('transport_reservations', jsonString);
  }

  @override
  Future<List<DateTime>> getReservableDates(
    String clinicalId,
    DateTime startDate,
    int days,
  ) async {
    await _initialize();
    
    final List<DateTime> reservableDates = [];
    
    for (int i = 0; i <= days; i++) {
      final date = startDate.add(Duration(days: i));
      if (isWeekAllowed(date) && hasAvailableOptions(DateFormat('yyyy-MM-dd').format(date))) {
        reservableDates.add(date);
      }
    }
    
    return reservableDates;
  }

  @override
  Future<List<Map<String, dynamic>>> getAvailableSchedules(
    String date,
    bool isOutbound,
  ) async {
    await _initialize();
    return getAvailableOptionsForDate(date, isOutbound: isOutbound);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchUpdatedReservations(
    List<Map<String, dynamic>> existingReservations,
  ) async {
    await _initialize();
    
    // Actualizar estados de las reservas existentes
    for (var reservation in _reservations) {
      if (reservation['outbound'] != null) {
        reservation['outbound']['status'] = _getStatusForReservation(reservation['outbound']);
      }
      if (reservation['return'] != null) {
        reservation['return']['status'] = _getStatusForReservation(reservation['return']);
      }
    }
    
    return List.from(_reservations);
  }

  @override
  Future<bool> reserveLeg({
    required String date,
    required String time,
    required bool isOutbound,
    String? service,
    String? clinicalAddress,
    String? clinicalName,
  }) async {
    try {
      await _initialize();
      
      final formattedTime = _formatTime(_parseTime(time));
      final leg = {
        'type': 'transport',
        'date': date,
        'origin': isOutbound ? 'Campus Universidad' : (clinicalName ?? 'Campo Clínico'),
        'destination': isOutbound ? (clinicalName ?? 'Campo Clínico') : 'Campus Universidad',
        'originAddress': isOutbound ? 'Campus Universitario, Santiago' : (clinicalAddress ?? ''),
        'destinationAddress': isOutbound ? (clinicalAddress ?? '') : 'Campus Universitario, Santiago',
        'originTime': formattedTime,
        'service': service ?? 'Transporte',
        'details': isOutbound
            ? 'Campus Universidad a Campo Clínico (IDA)'
            : 'Campo Clínico a Campus Universidad (REGRESO)',
        'highlighted': true,
        'status': TransportReservationStatus.pendiente.displayName,
      };

      var found = false;
      for (var res in _reservations) {
        if (isOutbound && res['outbound'] == null) {
          res['outbound'] = leg;
          found = true;
          break;
        }
        if (!isOutbound && res['return'] == null) {
          res['return'] = leg;
          found = true;
          break;
        }
      }

      if (!found) {
        final reservation = {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'outbound': isOutbound ? leg : null,
          'return': isOutbound ? null : leg,
        };
        _reservations.add(reservation);
      }

      _sortReservations();
      await saveReservations(_reservations);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> cancelLeg({
    required String date,
    required String time,
    required bool isOutbound,
  }) async {
    try {
      await _initialize();
      
      final formatted = _formatTime(_parseTime(time));
      for (int i = 0; i < _reservations.length; i++) {
        final res = _reservations[i];
        if (isOutbound &&
            res['outbound'] != null &&
            res['outbound']['date'] == date &&
            res['outbound']['originTime'] == formatted) {
          res['outbound'] = null;
          if (res['outbound'] == null && res['return'] == null) {
            _reservations.removeAt(i);
          }
          _sortReservations();
          await saveReservations(_reservations);
          return true;
        }
        if (!isOutbound &&
            res['return'] != null &&
            res['return']['date'] == date &&
            res['return']['originTime'] == formatted) {
          res['return'] = null;
          if (res['outbound'] == null && res['return'] == null) {
            _reservations.removeAt(i);
          }
          _sortReservations();
          await saveReservations(_reservations);
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  bool hasOutboundOnDate(String date) {
    return _reservations.any((r) => r['outbound'] != null && r['outbound']['date'] == date);
  }

  @override
  bool hasReturnOnDate(String date) {
    return _reservations.any((r) => r['return'] != null && r['return']['date'] == date);
  }

  @override
  bool isOptionReserved(String date, String time, {bool isOutbound = true}) {
    final formatted = _formatTime(_parseTime(time));
    if (isOutbound) {
      return _reservations.any((r) =>
          r['outbound'] != null &&
          r['outbound']['date'] == date &&
          r['outbound']['originTime'] == formatted);
    } else {
      return _reservations.any((r) =>
          r['return'] != null &&
          r['return']['date'] == date &&
          r['return']['originTime'] == formatted);
    }
  }

  @override
  List<Map<String, dynamic>> getOptionsForDate(
    String dateStr, {
    bool isOutbound = true,
  }) {
    if (_optionsByDate[dateStr]?[isOutbound] != null) {
      return _optionsByDate[dateStr]![isOutbound]!;
    }
    
    final transportTimes =
        isOutbound ? ['07:00 AM', '08:00 AM', '09:00 AM'] : ['01:00 PM', '03:00 PM', '05:00 PM'];
    
    final list = transportTimes
        .map((time) => {
              'service': 'Bus',
              'time': time,
              'available': true,
              'details': 'Inicio/Periferia'
            })
        .toList();
    
    _optionsByDate[dateStr] ??= {};
    _optionsByDate[dateStr]![isOutbound] = list;
    return list;
  }

  @override
  List<Map<String, dynamic>> getAvailableOptionsForDate(
    String dateStr, {
    bool isOutbound = true,
  }) {
    return getOptionsForDate(dateStr, isOutbound: isOutbound)
        .where((opt) => opt['available'] == true)
        .toList();
  }

  @override
  bool hasAvailableOptions(String dateStr) {
    final options = getOptionsForDate(dateStr);
    return options.any((opt) => opt['available'] == true);
  }

  @override
  bool isValidRange(DateTime start, DateTime end) {
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);
    if (startDate.isAtSameMomentAs(endDate)) {
      return true;
    }
    return !startDate.isAfter(endDate);
  }

  @override
  bool isWeekAllowed(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);

    const int cutoffWeekday = 4; // Jueves
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (normalizedDate.isAtSameMomentAs(today)) {
      return true;
    }

    final todayWeekday = now.weekday;
    final daysToNextMonday = (DateTime.monday - todayWeekday + 7) % 7;
    final nextMonday = today.add(Duration(days: daysToNextMonday == 0 ? 7 : daysToNextMonday));

    DateTime minReservableDate;
    if (todayWeekday <= cutoffWeekday) {
      minReservableDate = today;
    } else {
      minReservableDate = nextMonday;
    }

    return !normalizedDate.isBefore(minReservableDate);
  }

  @override
  DateTime getMinReservableDate() {
    const int cutoffWeekday = 4; // Jueves
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayWeekday = now.weekday;
    final daysToNextMonday = (DateTime.monday - todayWeekday + 7) % 7;
    final nextMonday = today.add(Duration(days: daysToNextMonday == 0 ? 7 : daysToNextMonday));
    
    DateTime minReservableDate;
    if (todayWeekday <= cutoffWeekday) {
      minReservableDate = nextMonday;
    } else {
      minReservableDate = nextMonday.add(const Duration(days: 7));
    }
    return minReservableDate;
  }

  @override
  String? getNextAvailableDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    for (int i = 0; i < 30; i++) {
      final futureDate = today.add(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(futureDate);
      if (hasAvailableOptions(dateStr)) {
        return DateFormat('EEE dd/MM', 'es_ES').format(futureDate);
      }
    }
    return null;
  }

  // Método para determinar el estado de una reserva basado en su fecha.
  String _getStatusForReservation(Map<String, dynamic> reservation) {
    final currentStatus = reservation['status'] as String?;
    
    if (currentStatus == TransportReservationStatus.aceptada.displayName) {
      final dateStr = reservation['date'] as String?;
      if (dateStr == null) {
        return TransportReservationStatus.pendiente.displayName;
      }
      
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final resDate = DateTime(date.year, date.month, date.day);
      
      if (resDate.isBefore(today)) {
        return TransportReservationStatus.finalizada.displayName;
      } else if (resDate.isAtSameMomentAs(today)) {
        return TransportReservationStatus.iniciada.displayName;
      } else {
        return TransportReservationStatus.aceptada.displayName;
      }
    } else {
      return currentStatus ?? TransportReservationStatus.pendiente.displayName;
    }
  }

  // Método para ordenar reservas por fecha.
  void _sortReservations() {
    _reservations.sort((a, b) {
      DateTime? dateA = _getEarliestDate(a);
      DateTime? dateB = _getEarliestDate(b);
      if (dateA == null && dateB == null) {
        return 0;
      }
      if (dateA == null) {
        return 1;
      }
      if (dateB == null) {
        return -1;
      }
      return dateB.compareTo(dateA);
    });
  }

  // Obtiene la fecha más temprana de una reserva (ida o vuelta).
  DateTime? _getEarliestDate(Map<String, dynamic> reservation) {
    DateTime? outboundDate;
    if (reservation['outbound'] != null && reservation['outbound']['date'] != null) {
      dynamic dateValue = reservation['outbound']['date'];
      if (dateValue is DateTime) {
        outboundDate = dateValue;
      } else {
        outboundDate = DateTime.parse(dateValue as String);
      }
    }
    
    DateTime? returnDate;
    if (reservation['return'] != null && reservation['return']['date'] != null) {
      dynamic dateValue = reservation['return']['date'];
      if (dateValue is DateTime) {
        returnDate = dateValue;
      } else {
        returnDate = DateTime.parse(dateValue as String);
      }
    }
    
    if (outboundDate != null && returnDate != null) {
      return outboundDate.isBefore(returnDate) ? outboundDate : returnDate;
    }
    return outboundDate ?? returnDate;
  }

  DateTime _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.length == 2) {
      final second = parts[1];
      final ampmMatch = RegExp(r'(am|pm)', caseSensitive: false).firstMatch(second);
      int hour = 0;
      int minute = 0;
      
      if (ampmMatch != null) {
        final ampm = ampmMatch.group(0)!.toLowerCase();
        final minuteStr = second.substring(0, ampmMatch.start).trim();
        minute = int.tryParse(minuteStr) ?? 0;
        hour = int.tryParse(parts[0]) ?? 0;
        
        if (ampm == 'pm' && hour < 12) {
          hour += 12;
        } else if (ampm == 'am' && hour == 12) {
          hour = 0;
        }
      } else {
        hour = int.tryParse(parts[0]) ?? 0;
        minute = int.tryParse(second) ?? 0;
      }
      
      return DateTime(0, 1, 1, hour, minute);
    }
    return DateTime(0, 1, 1, 0, 0);
  }

  String _formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:mobile/domain/entities/transport_reservation_status.dart';

class TransportReservationsProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _reservations = [];
  final Map<String, Map<bool, List<Map<String, dynamic>>>> _optionsByDate = {};

  Map<String, String>? _selectedLocation;
  String? _selectedOutboundTime;
  String? _selectedReturnTime;
  String? _selectedDate;
  String? _selectedReturnDate;
  String? _selectedService;

  List<Map<String, dynamic>> get reservations => _reservations;

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
  Map<String, Map<bool, List<Map<String, dynamic>>>> get optionsByDate => _optionsByDate;

  String? get nextAvailableDate {
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

  // Mock data
  Future<void> fetchReservations() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('transport_reservations');
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      _reservations = jsonList.map((json) => Map<String, dynamic>.from(json)).toList();
      // Actualizar el estado de cada reserva según la lógica definida
      for (var reservation in _reservations) {
        if (reservation['outbound'] != null) {
          reservation['outbound']['status'] = getStatusForReservation(reservation['outbound']);
        }
        if (reservation['return'] != null) {
          reservation['return']['status'] = getStatusForReservation(reservation['return']);
        }
      }
    }

    sortReservations();
    notifyListeners();
  }

  Future<void> saveReservations() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(_reservations.map((r) => Map<String, dynamic>.from(r)).toList());
    await prefs.setString('transport_reservations', jsonString);
  }

  bool isValidRange(DateTime start, DateTime end) {
    if (start.isAfter(end)) return false;
    final daysDiff = end.difference(start).inDays + 1;
    return daysDiff <= 7 && daysDiff >= 1;
  }

  List<Map<String, dynamic>> getAvailableOptionsForDate(String dateStr, {bool isOutbound = true}) {
    return getOptionsForDate(dateStr, isOutbound: isOutbound).where((opt) => opt['available'] == true).toList();
  }

  bool isWeekAllowed(DateTime monday) {
    if (monday.weekday != DateTime.monday) return false;
    const int cutoffWeekday = 3; 
    final now = DateTime.now();
    final todayWeekday = now.weekday;
    final daysToNextMonday = (DateTime.monday - todayWeekday + 7) % 7;
    final nextMonday = now.add(Duration(days: daysToNextMonday == 0 ? 7 : daysToNextMonday));
    final subsequentMonday = nextMonday.add(const Duration(days: 7));
    DateTime minReservableMonday;
    if (todayWeekday < cutoffWeekday) {
      minReservableMonday = nextMonday;
    } else {
      minReservableMonday = subsequentMonday;
    }
    return !monday.isBefore(minReservableMonday);
  }

  List<Map<String, dynamic>> getOptionsForDate(String dateStr, {bool isOutbound = true}) {
    if (_optionsByDate[dateStr]?[isOutbound] != null) {
      return _optionsByDate[dateStr]![isOutbound]!;
    }
    final transportTimes = isOutbound
        ? ['07:00 AM', '08:00 AM', '09:00 AM']
        : ['13:00 PM', '15:00 PM', '17:00 PM'];
    final list = transportTimes.map((time) => {'service': 'Bus', 'time': time, 'available': true, 'details': 'Inicio/Periferia'}).toList();
    _optionsByDate[dateStr] ??= {};
    _optionsByDate[dateStr]![isOutbound] = list;
    return list;
  }

  bool hasAvailableOptions(String dateStr) {
    final options = getOptionsForDate(dateStr);
    return options.any((opt) => opt['available'] == true);
  }
  
  void updateReservations(List<Map<String, dynamic>> newReservations) async {
    _reservations = newReservations;
    sortReservations();
    await saveReservations();
    notifyListeners();
  }

  void sortReservations() {
    _reservations.sort((a, b) {
      DateTime? dateA = _getEarliestDate(a);
      DateTime? dateB = _getEarliestDate(b);
      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;
      return dateB.compareTo(dateA);
    });
  }

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

  void addReservation(Map<String, dynamic> reservation) async {
    dynamic dateValue = reservation['date'];
    if (dateValue == null) {
      reservation['date'] = DateFormat('yyyy-MM-dd').format(DateTime.now());
    } else if (dateValue is DateTime) {
      reservation['date'] = DateFormat('yyyy-MM-dd').format(dateValue);
    }
    reservation['service'] ??= 'Transporte';
    reservation['details'] ??= '';
    reservation['status'] ??= TransportReservationStatus.pendiente.displayName;
    _reservations.add(reservation);
    sortReservations();
    await saveReservations();
    notifyListeners();
  }

  void addWeekReservation(Map<String, dynamic> baseReservation, DateTime weekStart) async {
    baseReservation['status'] ??= TransportReservationStatus.pendiente.displayName;
    final weekEnd = weekStart.add(const Duration(days: 6));
    if (!isValidRange(weekStart, weekEnd)) return;
    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      if (hasAvailableOptions(dateStr)) {
        final reservation = Map<String, dynamic>.from(baseReservation);
        reservation['date'] = dateStr;
        _reservations.add(reservation);
      }
    }
    sortReservations();
    await saveReservations();
    notifyListeners();
  }

  Map<String, String>? get selectedLocation => _selectedLocation;
  set selectedLocation(Map<String, String>? value) {
    _selectedLocation = value;
    notifyListeners();
  }

  String? get selectedOutboundTime => _selectedOutboundTime;
  set selectedOutboundTime(String? value) {
    _selectedOutboundTime = value;
    notifyListeners();
  }

  String? get selectedReturnTime => _selectedReturnTime;
  set selectedReturnTime(String? value) {
    _selectedReturnTime = value;
    notifyListeners();
  }

  String? get selectedDate => _selectedDate;
  set selectedDate(dynamic value) {
    if (value is DateTime) {
      _selectedDate = DateFormat('yyyy-MM-dd').format(value);
    } else {
      _selectedDate = value as String?;
    }
    notifyListeners();
  }

  String? get selectedReturnDate => _selectedReturnDate;
  set selectedReturnDate(dynamic value) {
    if (value is DateTime) {
      _selectedReturnDate = DateFormat('yyyy-MM-dd').format(value);
    } else {
      _selectedReturnDate = value as String?;
    }
    notifyListeners();
  }

  String? get selectedService => _selectedService;
  set selectedService(String? value) {
    _selectedService = value;
    notifyListeners();
  }

  void addOutboundReservation() async {
    if (_selectedDate == null || _selectedLocation == null || _selectedOutboundTime == null) return;

    dynamic selectedDateValue = _selectedDate;
    String outboundDateStr;
    if (selectedDateValue is DateTime) {
      outboundDateStr = DateFormat('yyyy-MM-dd').format(selectedDateValue);
    } else {
      outboundDateStr = selectedDateValue as String;
    }

    if (hasOutboundOnDate(outboundDateStr)) return;

    final outboundTime = _parseTime(_selectedOutboundTime!);

    final outboundReservation = {
      'type': 'transport',
      'date': outboundDateStr,
      'origin': 'Campus Universidad',
      'destination': _selectedLocation!['name'],
      'originAddress': 'Campus Universitario, Santiago',
      'destinationAddress': _selectedLocation!['address'],
      'originTime': _formatTime(outboundTime),
      'service': _selectedService ?? 'Transporte',
      'details': 'Campus Universidad a Campo Clínico (IDA)',
      'highlighted': true,
      'status': TransportReservationStatus.pendiente.displayName,
    };

    final reservation = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'outbound': outboundReservation,
      'return': null,
    };

    _reservations.add(reservation);
    sortReservations();
    await saveReservations();
    notifyListeners();
  }

  void addReturnReservation() async {
    if (_selectedReturnDate == null || _selectedLocation == null || _selectedReturnTime == null) return;

    dynamic returnDateValue = _selectedReturnDate;
    String returnDateStr;
    if (returnDateValue is DateTime) {
      returnDateStr = DateFormat('yyyy-MM-dd').format(returnDateValue);
    } else {
      returnDateStr = returnDateValue as String;
    }

    if (hasReturnOnDate(returnDateStr)) return;

    final returnTime = _parseTime(_selectedReturnTime!);

    final returnReservation = {
      'type': 'transport',
      'date': returnDateStr,
      'origin': _selectedLocation!['name'],
      'destination': 'Campus Universidad',
      'originAddress': _selectedLocation!['address'],
      'destinationAddress': 'Campus Universitario, Santiago',
      'originTime': _formatTime(returnTime),
      'service': _selectedService ?? 'Transporte',
      'details': 'Campo Clínico a Campus Universidad (REGRESO)',
      'highlighted': true,
      'status': TransportReservationStatus.pendiente.displayName,
    };

    final reservation = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'outbound': null,
      'return': returnReservation,
    };

    _reservations.add(reservation);
    sortReservations();
    await saveReservations();
    notifyListeners();

    _selectedLocation = null;
    _selectedReturnTime = null;
    _selectedReturnDate = null;
    _selectedService = null;
  }

  void addRoundTripReservation() async {
    if (_selectedDate == null || _selectedLocation == null || _selectedOutboundTime == null ||
        _selectedReturnDate == null || _selectedReturnTime == null) return;

    dynamic outboundDateValue = _selectedDate;
    String outboundDateStr;
    if (outboundDateValue is DateTime) {
      outboundDateStr = DateFormat('yyyy-MM-dd').format(outboundDateValue);
    } else {
      outboundDateStr = outboundDateValue as String;
    }

    dynamic returnDateValue = _selectedReturnDate;
    String returnDateStr;
    if (returnDateValue is DateTime) {
      returnDateStr = DateFormat('yyyy-MM-dd').format(returnDateValue);
    } else {
      returnDateStr = returnDateValue as String;
    }

    if (hasReturnOnDate(returnDateStr)) return;

    final outboundTime = _parseTime(_selectedOutboundTime!);
    final returnTime = _parseTime(_selectedReturnTime!);

    final outboundReservation = {
      'type': 'transport',
      'date': outboundDateStr,
      'origin': 'Campus Universidad',
      'destination': _selectedLocation!['name'],
      'originAddress': 'Campus Universitario, Santiago',
      'destinationAddress': _selectedLocation!['address'],
      'originTime': _formatTime(outboundTime),
      'service': _selectedService ?? 'Transporte',
      'details': 'Campus Universidad a Campo Clínico (IDA)',
      'highlighted': true,
      'status': TransportReservationStatus.pendiente.displayName,
    };

    final returnReservation = {
      'type': 'transport',
      'date': returnDateStr,
      'origin': _selectedLocation!['name'],
      'destination': 'Campus Universidad',
      'originAddress': _selectedLocation!['address'],
      'destinationAddress': 'Campus Universitario, Santiago',
      'originTime': _formatTime(returnTime),
      'service': _selectedService ?? 'Transporte',
      'details': 'Campo Clínico a Campus Universidad (REGRESO)',
      'highlighted': true,
      'status': TransportReservationStatus.pendiente.displayName,
    };

    if (hasOutboundOnDate(outboundDateStr)) {
      final existingReservation = _reservations.firstWhere(
        (r) => r['outbound'] != null && r['outbound']['date'] == outboundDateStr,
        orElse: () => {},
      );
      if (existingReservation.isNotEmpty) {
        existingReservation['return'] = returnReservation;
        sortReservations();
        await saveReservations();
        notifyListeners();
      }
    } else {
      final reservation = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'outbound': outboundReservation,
        'return': returnReservation,
      };

      _reservations.add(reservation);
      sortReservations();
      await saveReservations();
      notifyListeners();
    }

    _selectedLocation = null;
    _selectedOutboundTime = null;
    _selectedReturnTime = null;
    _selectedDate = null;
    _selectedReturnDate = null;
    _selectedService = null;
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

  bool hasOutboundOnDate(String date) {
    return _reservations.any((r) =>
      r['outbound'] != null && r['outbound']['date'] == date
    );
  }

  bool hasReturnOnDate(String date) {
    return _reservations.any((r) =>
      r['return'] != null && r['return']['date'] == date
    );
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

  String getStatusForReservation(Map<String, dynamic> reservation) {
    final currentStatus = reservation['status'] as String?;
    if (currentStatus == TransportReservationStatus.aceptada.displayName) {
      final dateStr = reservation['date'] as String?;
      if (dateStr == null) return TransportReservationStatus.pendiente.displayName;
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

  // Método para hacer refresh a status de reservas (cambios de status que llegan desde API)
  Future<void> fetchUpdatedReservations() async {
    await fetchReservations();
  }
}

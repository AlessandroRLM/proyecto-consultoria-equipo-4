import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TransportReservationsProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _reservations = [];
  final Map<String, List<Map<String, dynamic>>> _optionsByDate = {}; 

  String? _selectedLocation;
  String? _selectedOutboundTime;
  String? _selectedReturnTime;
  String? _selectedDate;
  String? _selectedReturnDate;
  String? _selectedService;

  List<Map<String, dynamic>> get reservations => _reservations;

  List<Map<String, dynamic>> get futureReservations {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    var futureRes = _reservations.where((r) {
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
      return resDateA.compareTo(resDateB); 
    });
    return futureRes;
  }
  Map<String, List<Map<String, dynamic>>> get optionsByDate => _optionsByDate;

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
    final now = DateTime.now();
    final todayWeekday = now.weekday;
    final daysToNextMonday = (DateTime.monday - todayWeekday + 7) % 7;
    final minReservableMonday = now.add(Duration(days: daysToNextMonday == 0 ? 7 : daysToNextMonday));
    return !monday.isBefore(minReservableMonday);
  }

  List<Map<String, dynamic>> getOptionsForDate(String dateStr, {bool isOutbound = true}) {
    if (_optionsByDate[dateStr] != null) {
      return _optionsByDate[dateStr]!;
    }
    final transportTimes = isOutbound
        ? ['07:00 AM', '08:00 AM', '09:00 AM']
        : ['13:00 PM', '15:00 PM', '17:00 PM'];
    return transportTimes.map((time) => {'service': 'Bus', 'time': time, 'available': true, 'details': 'Inicio/Periferia'}).toList();
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
    _reservations.removeWhere((r) => r['date'] == null);
    _reservations.sort((a, b) {
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
      return dateB.compareTo(dateA); 
    });
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
    _reservations.add(reservation);
    sortReservations();
    await saveReservations();
    notifyListeners();
  }

  void addWeekReservation(Map<String, dynamic> baseReservation, DateTime weekStart) async {
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

  String? get selectedLocation => _selectedLocation;
  set selectedLocation(String? value) {
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

  void addRoundTripReservation() async {
    if (_selectedDate == null || _selectedLocation == null || _selectedOutboundTime == null || _selectedReturnTime == null) return;

    dynamic selectedDateValue = _selectedDate;
    String outboundDateStr;
    if (selectedDateValue is DateTime) {
      outboundDateStr = DateFormat('yyyy-MM-dd').format(selectedDateValue);
    } else {
      outboundDateStr = selectedDateValue as String;
    }
    dynamic returnDateValue = _selectedReturnDate ?? _selectedDate;
    String returnDateStr;
    if (returnDateValue is DateTime) {
      returnDateStr = DateFormat('yyyy-MM-dd').format(returnDateValue);
    } else {
      returnDateStr = returnDateValue as String;
    }
    final outboundDate = DateTime.parse(outboundDateStr);
    final returnDate = DateTime.parse(returnDateStr);
    if (returnDate.isAfter(outboundDate.add(const Duration(days: 7)))) {
      return;
    }

    final outboundTime = _parseTime(_selectedOutboundTime!);
    final returnTime = _parseTime(_selectedReturnTime!);

    final String groupId = DateTime.now().millisecondsSinceEpoch.toString();

    final outboundReservation = {
      'type': 'transport',
      'date': outboundDateStr,
      'origin': 'Campus Universidad',
      'destination': _selectedLocation,
      'originTime': _formatTime(outboundTime),
      'details': 'Campus Universidad a Campo Clínico (IDA)',
      'highlighted': true,
      'groupId': groupId,
    };

    final returnReservation = {
      'type': 'transport',
      'date': returnDateStr,
      'origin': _selectedLocation,
      'destination': 'Campus Universidad',
      'originTime': _formatTime(returnTime),
      'service': _selectedService ?? 'Transporte',
      'details': 'Campo Clínico a Campus Universidad (REGRESO)',
      'highlighted': true,
      'groupId': groupId,
    };

    _reservations.add(outboundReservation);
    _reservations.add(returnReservation);
    sortReservations();
    await saveReservations();
    notifyListeners();

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
}

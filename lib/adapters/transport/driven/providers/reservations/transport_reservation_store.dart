import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

typedef ReservationStatusResolver = String Function(
    Map<String, dynamic> reservation);

class TransportReservationStore {
  TransportReservationStore({SharedPreferences? preferences})
      : _preferences = preferences;

  final SharedPreferences? _preferences;

  static const _storageKey = 'transport_reservations';

  List<Map<String, dynamic>> _reservations = [];

  List<Map<String, dynamic>> get reservations => _reservations;

  Future<void> load({
    required ReservationStatusResolver statusResolver,
  }) async {
    final prefs = _preferences ?? await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString == null) {
      _reservations = [];
      return;
    }

    final List<dynamic> jsonList = json.decode(jsonString);
    _reservations =
        jsonList.map((json) => Map<String, dynamic>.from(json)).toList();

    for (final reservation in _reservations) {
      final outbound = reservation['outbound'];
      if (outbound != null) {
        outbound['status'] = statusResolver(outbound);
      }
      final returnLeg = reservation['return'];
      if (returnLeg != null) {
        returnLeg['status'] = statusResolver(returnLeg);
      }
    }

    sort();
  }

  Future<void> persist() async {
    final prefs = _preferences ?? await SharedPreferences.getInstance();
    final jsonString = json.encode(
      _reservations.map((r) => Map<String, dynamic>.from(r)).toList(),
    );
    await prefs.setString(_storageKey, jsonString);
  }

  void replace(List<Map<String, dynamic>> newReservations) {
    _reservations = List<Map<String, dynamic>>.from(
      newReservations.map((r) => Map<String, dynamic>.from(r)),
    );
    sort();
  }

  void addReservation(Map<String, dynamic> reservation) {
    _reservations.add(reservation);
    sort();
  }

  void addReservations(Iterable<Map<String, dynamic>> reservations) {
    _reservations.addAll(reservations);
    sort();
  }

  void sort() {
    _reservations.sort((a, b) {
      final dateA = _getEarliestDate(a);
      final dateB = _getEarliestDate(b);
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

  List<Map<String, dynamic>> futureReservations() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final List<Map<String, dynamic>> allLegs = [];
    for (final reservation in _reservations) {
      final outbound = reservation['outbound'];
      if (outbound != null) {
        allLegs.add(outbound);
      }
      final returnLeg = reservation['return'];
      if (returnLeg != null) {
        allLegs.add(returnLeg);
      }
    }

    final futureRes = allLegs.where((r) {
      final dateValue = r['date'];
      if (dateValue == null) {
        return false;
      }
      final date =
          dateValue is DateTime ? dateValue : DateTime.tryParse(dateValue);
      if (date == null) {
        return false;
      }
      final resDate = DateTime(date.year, date.month, date.day);
      return !resDate.isBefore(today);
    }).toList();

    futureRes.sort((a, b) {
      final dateValueA = a['date'];
      final dateValueB = b['date'];
      if (dateValueA == null || dateValueB == null) {
        return 0;
      }
      final dateA =
          dateValueA is DateTime ? dateValueA : DateTime.parse(dateValueA);
      final dateB =
          dateValueB is DateTime ? dateValueB : DateTime.parse(dateValueB);
      final resDateA = DateTime(dateA.year, dateA.month, dateA.day);
      final resDateB = DateTime(dateB.year, dateB.month, dateB.day);
      final dateCompare = resDateA.compareTo(resDateB);
      if (dateCompare != 0) {
        return dateCompare;
      }
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

  bool hasOutboundOnDate(
    String date, {
    Map<String, String>? location,
  }) {
    return _reservations.any(
      (r) =>
          r['outbound'] != null &&
          r['outbound']['date'] == date &&
          _matchesLocation(
            r['outbound'] as Map<String, dynamic>,
            location,
            isOutbound: true,
          ),
    );
  }

  bool hasReturnOnDate(
    String date, {
    Map<String, String>? location,
  }) {
    return _reservations.any(
      (r) =>
          r['return'] != null &&
          r['return']['date'] == date &&
          _matchesLocation(
            r['return'] as Map<String, dynamic>,
            location,
            isOutbound: false,
          ),
    );
  }

  bool isLegReserved({
    required String date,
    required String formattedTime,
    required bool isOutbound,
    Map<String, String>? location,
  }) {
    if (isOutbound) {
      return _reservations.any(
        (r) =>
            r['outbound'] != null &&
            r['outbound']['date'] == date &&
            r['outbound']['originTime'] == formattedTime &&
            _matchesLocation(
              r['outbound'] as Map<String, dynamic>,
              location,
              isOutbound: true,
            ),
      );
    } else {
      return _reservations.any(
        (r) =>
            r['return'] != null &&
            r['return']['date'] == date &&
            r['return']['originTime'] == formattedTime &&
            _matchesLocation(
              r['return'] as Map<String, dynamic>,
              location,
              isOutbound: false,
            ),
      );
    }
  }

  bool attachLeg(
    Map<String, dynamic> leg, {
    required bool isOutbound,
  }) {
    for (final reservation in _reservations) {
      if (isOutbound && reservation['outbound'] == null) {
        reservation['outbound'] = leg;
        sort();
        return true;
      }
      if (!isOutbound && reservation['return'] == null) {
        reservation['return'] = leg;
        sort();
        return true;
      }
    }

    final reservation = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'outbound': isOutbound ? leg : null,
      'return': isOutbound ? null : leg,
    };
    _reservations.add(reservation);
    sort();
    return true;
  }

  bool cancelLeg({
    required String date,
    required String formattedTime,
    required bool isOutbound,
    Map<String, String>? location,
  }) {
    for (int i = 0; i < _reservations.length; i++) {
      final res = _reservations[i];
      final leg = isOutbound ? res['outbound'] : res['return'];
      if (leg != null &&
          leg['date'] == date &&
          leg['originTime'] == formattedTime &&
          _matchesLocation(
            Map<String, dynamic>.from(leg),
            location,
            isOutbound: isOutbound,
          )) {
        if (isOutbound) {
          res['outbound'] = null;
        } else {
          res['return'] = null;
        }
        if (res['outbound'] == null && res['return'] == null) {
          _reservations.removeAt(i);
        }
        sort();
        return true;
      }
    }
    return false;
  }

  bool _matchesLocation(
    Map<String, dynamic> leg,
    Map<String, String>? location, {
    required bool isOutbound,
  }) {
    if (location == null || location.isEmpty) {
      return true;
    }
    final targetKeys = _keysForLocation(location);
    if (targetKeys.isEmpty) {
      return true;
    }
    final legKeys = _keysForLeg(leg, isOutbound: isOutbound);
    if (legKeys.isEmpty) {
      return false;
    }
    return legKeys.any(targetKeys.contains);
  }

  Set<String> _keysForLocation(Map<String, String>? location) {
    if (location == null) {
      return const <String>{};
    }
    final keys = <String>{};
    final campusId = _normalizeId(location['campus_id']);
    if (campusId != null) {
      keys.add('campus:$campusId');
    }
    final clinicalId = _normalizeId(location['clinical_id']);
    if (clinicalId != null) {
      keys.add('clinical:$clinicalId');
    }
    final nameKey = _nameKey(location['name']);
    if (nameKey != null) {
      keys.add(nameKey);
    }
    return keys;
  }

  Set<String> _keysForLeg(
    Map<String, dynamic> leg, {
    required bool isOutbound,
  }) {
    final keys = <String>{};
    final storedKey = _normalizeId(leg['locationKey']?.toString());
    if (storedKey != null) {
      keys.add(storedKey);
    }
    final campusId = _normalizeId(leg['campusId']?.toString());
    if (campusId != null) {
      keys.add('campus:$campusId');
    }
    final clinicalId = _normalizeId(leg['clinicalId']?.toString());
    if (clinicalId != null) {
      keys.add('clinical:$clinicalId');
    }
    final nameSource =
        isOutbound ? leg['destination'] as String? : leg['origin'] as String?;
    final nameKey = _nameKey(nameSource);
    if (nameKey != null) {
      keys.add(nameKey);
    }
    return keys;
  }

  String? _normalizeId(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  String? _nameKey(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return 'name:${trimmed.toLowerCase()}';
  }

  DateTime? _getEarliestDate(Map<String, dynamic> reservation) {
    DateTime? outboundDate;
    final outbound = reservation['outbound'];
    if (outbound != null && outbound['date'] != null) {
      final dateValue = outbound['date'];
      outboundDate = dateValue is DateTime
          ? dateValue
          : DateTime.tryParse(dateValue as String);
    }
    DateTime? returnDate;
    final returnLeg = reservation['return'];
    if (returnLeg != null && returnLeg['date'] != null) {
      final dateValue = returnLeg['date'];
      returnDate = dateValue is DateTime
          ? dateValue
          : DateTime.tryParse(dateValue as String);
    }

    if (outboundDate != null && returnDate != null) {
      return outboundDate.isBefore(returnDate) ? outboundDate : returnDate;
    }
    return outboundDate ?? returnDate;
  }
}

import 'package:intl/intl.dart';
import 'package:mobile/domain/models/transport/service_model.dart';

class TransportServiceOptionsCache {
  final Map<String, Map<bool, List<Map<String, dynamic>>>> _optionsByDate = {};

  Map<String, Map<bool, List<Map<String, dynamic>>>> get optionsByDate =>
      _optionsByDate;

  void clear() => _optionsByDate.clear();

  List<Map<String, dynamic>> getOptionsForDate({
    required String dateStr,
    bool isOutbound = true,
    required Iterable<TransportServiceModel> services,
    Map<String, String>? selectedLocation,
  }) {
    final cached = _optionsByDate[dateStr]?[isOutbound];
    if (cached != null) {
      return cached;
    }

    final selectedDate = DateTime.tryParse(dateStr);
    final filtered = services.where((service) {
      final type = service.typeService.toLowerCase();
      final matchesTrip = isOutbound ? type == 'ida' : type == 'regreso';
      if (!matchesTrip) {
        return false;
      }
      if (selectedDate != null &&
          !_serviceRunsOnDate(service: service, date: selectedDate)) {
        return false;
      }
      return _serviceMatchesLocation(
        service: service,
        location: selectedLocation,
      );
    }).map(_mapServiceToOption).toList();

    _optionsByDate[dateStr] ??= {};
    _optionsByDate[dateStr]![isOutbound] = filtered;
    return filtered;
  }

  List<Map<String, dynamic>> getAvailableOptionsForDate({
    required String dateStr,
    bool isOutbound = true,
    required Iterable<TransportServiceModel> services,
    Map<String, String>? selectedLocation,
  }) {
    return getOptionsForDate(
      dateStr: dateStr,
      isOutbound: isOutbound,
      services: services,
      selectedLocation: selectedLocation,
    ).where((opt) => opt['available'] == true).toList();
  }

  bool hasAvailableOptions({
    required String dateStr,
    bool isOutbound = true,
    required Iterable<TransportServiceModel> services,
    Map<String, String>? selectedLocation,
  }) {
    return getOptionsForDate(
      dateStr: dateStr,
      isOutbound: isOutbound,
      services: services,
      selectedLocation: selectedLocation,
    ).any((opt) => opt['available'] == true);
  }

  DateTime? findNextAvailableDate({
    int maxDays = 30,
    DateTime? from,
    required Iterable<TransportServiceModel> services,
    Map<String, String>? selectedLocation,
  }) {
    final now = from ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    for (var i = 0; i < maxDays; i++) {
      final candidate = today.add(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(candidate);
      if (hasAvailableOptions(
        dateStr: dateStr,
        services: services,
        selectedLocation: selectedLocation,
      )) {
        return candidate;
      }
    }
    return null;
  }

  Map<String, dynamic> _mapServiceToOption(TransportServiceModel service) {
    final itineraryNames =
        service.itinerary.map((stop) => stop.name).join(' - ');
    return {
      'service': service.name,
      'serviceId': service.id,
      'time': _formatDeparture(service.departure),
      'available': true,
      'details': itineraryNames.isNotEmpty
          ? itineraryNames
          : service.nameItinerary,
      'rawDeparture': service.departure,
      'type': service.typeService,
    };
  }

  String _formatDeparture(String departure) {
    try {
      final parts = departure.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final dt = DateTime(0, 1, 1, hour, minute);
      return DateFormat('hh:mm a').format(dt);
    } catch (_) {
      return departure;
    }
  }

  bool _serviceRunsOnDate({
    required TransportServiceModel service,
    required DateTime date,
  }) {
    switch (date.weekday) {
      case DateTime.monday:
        return service.monTrip;
      case DateTime.tuesday:
        return service.tueTrip;
      case DateTime.wednesday:
        return service.wedTrip;
      case DateTime.thursday:
        return service.thuTrip;
      case DateTime.friday:
        return service.friTrip;
      case DateTime.saturday:
        return service.satTrip;
      case DateTime.sunday:
        return service.sunTrip;
      default:
        return true;
    }
  }

  bool _serviceMatchesLocation({
    required TransportServiceModel service,
    Map<String, String>? location,
  }) {
    if (location == null) {
      return true;
    }

    final campusId = location['campus_id'];
    final clinicalId = location['clinical_id'];
    if ((campusId == null || campusId.isEmpty) &&
        (clinicalId == null || clinicalId.isEmpty)) {
      return true;
    }

    return service.itinerary.any((stop) {
      final matchesCampus = campusId != null &&
          campusId.isNotEmpty &&
          stop.campusId != null &&
          stop.campusId.toString() == campusId;
      final matchesClinical = clinicalId != null &&
          clinicalId.isNotEmpty &&
          stop.clinicalId != null &&
          stop.clinicalId.toString() == clinicalId;
      return matchesCampus || matchesClinical;
    });
  }
}

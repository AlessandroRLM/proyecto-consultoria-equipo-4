import 'package:mobile/adapters/transport/driven/providers/reservations/transport_time_utils.dart';
import 'package:mobile/domain/entities/transport_reservation_status.dart';

class TransportReservationBuilder {
  TransportReservationBuilder({TransportTimeUtils? timeUtils})
      : _timeUtils = timeUtils ?? const TransportTimeUtils();

  final TransportTimeUtils _timeUtils;

  static const String _campusName = 'Campus Universidad';
  static const String _campusAddress = 'Campus Universitario, Santiago';
  static const String _defaultService = 'Transporte';
  static const String _defaultLocationName = 'Campo Clinico';

  Map<String, dynamic> buildOutboundReservation({
    required String date,
    required Map<String, String> location,
    required String time,
    String? service,
  }) {
    final outbound = _buildOutboundLeg(
      date: date,
      location: location,
      time: time,
      service: service,
    );
    return _composeReservation(outbound: outbound);
  }

  Map<String, dynamic> buildReturnReservation({
    required String date,
    required Map<String, String> location,
    required String time,
    String? service,
  }) {
    final returnLeg = _buildReturnLeg(
      date: date,
      location: location,
      time: time,
      service: service,
    );
    return _composeReservation(returnLeg: returnLeg);
  }

  Map<String, dynamic> buildRoundTripReservation({
    required Map<String, String> location,
    required String outboundDate,
    required String returnDate,
    required String outboundTime,
    required String returnTime,
    String? service,
  }) {
    final outbound = _buildOutboundLeg(
      date: outboundDate,
      location: location,
      time: outboundTime,
      service: service,
    );
    final returnLeg = _buildReturnLeg(
      date: returnDate,
      location: location,
      time: returnTime,
      service: service,
    );
    return _composeReservation(outbound: outbound, returnLeg: returnLeg);
  }

  Map<String, dynamic> buildFlexibleLeg({
    required bool isOutbound,
    required String date,
    Map<String, String>? location,
    required String time,
    String? service,
  }) {
    final locationName = location?['name'] ?? _defaultLocationName;
    final locationAddress = location?['address'] ?? '';
    final origin = isOutbound ? _campusName : locationName;
    final destination = isOutbound ? locationName : _campusName;
    final originAddress = isOutbound ? _campusAddress : locationAddress;
    final destinationAddress = isOutbound ? locationAddress : _campusAddress;
    final details = isOutbound
        ? 'Campus Universidad a Campo Clinico (IDA)'
        : 'Campo Clinico a Campus Universidad (REGRESO)';
    return _buildLeg(
      date: date,
      origin: origin,
      destination: destination,
      originAddress: originAddress,
      destinationAddress: destinationAddress,
      time: time,
      details: details,
      service: service,
      location: location,
    );
  }

  String normalizeTime(String time) => _formatTime(time);

  Map<String, dynamic> _buildOutboundLeg({
    required String date,
    required Map<String, String> location,
    required String time,
    String? service,
  }) {
    final destination = location['name'] ?? _defaultLocationName;
    final destinationAddress = location['address'] ?? '';
    return _buildLeg(
      date: date,
      origin: _campusName,
      destination: destination,
      originAddress: _campusAddress,
      destinationAddress: destinationAddress,
      time: time,
      details: 'Campus Universidad a Campo Clinico (IDA)',
      service: service,
      location: location,
    );
  }

  Map<String, dynamic> _buildReturnLeg({
    required String date,
    required Map<String, String> location,
    required String time,
    String? service,
  }) {
    final origin = location['name'] ?? _defaultLocationName;
    final originAddress = location['address'] ?? '';
    return _buildLeg(
      date: date,
      origin: origin,
      destination: _campusName,
      originAddress: originAddress,
      destinationAddress: _campusAddress,
      time: time,
      details: 'Campo Clinico a Campus Universidad (REGRESO)',
      service: service,
      location: location,
    );
  }

  Map<String, dynamic> _buildLeg({
    required String date,
    required String origin,
    required String destination,
    required String originAddress,
    required String destinationAddress,
    required String time,
    required String details,
    String? service,
    Map<String, String>? location,
  }) {
    final campusId = _normalizeId(location?['campus_id']);
    final clinicalId = _normalizeId(location?['clinical_id']);
    final locationKey = _deriveLocationKey(location);
    return {
      'type': 'transport',
      'date': date,
      'origin': origin,
      'destination': destination,
      'originAddress': originAddress,
      'destinationAddress': destinationAddress,
      'originTime': _formatTime(time),
      'service': service ?? _defaultService,
      'details': details,
      'highlighted': true,
      'status': TransportReservationStatus.pendiente.displayName,
      if (campusId != null) 'campusId': campusId,
      if (clinicalId != null) 'clinicalId': clinicalId,
      if (locationKey != null) 'locationKey': locationKey,
    };
  }

  Map<String, dynamic> _composeReservation({
    Map<String, dynamic>? outbound,
    Map<String, dynamic>? returnLeg,
  }) {
    return {
      'id': _generateReservationId(),
      'outbound': outbound,
      'return': returnLeg,
    };
  }

  String _generateReservationId() =>
      DateTime.now().millisecondsSinceEpoch.toString();

  String _formatTime(String time) {
    final parsed = _timeUtils.parseTime(time);
    return _timeUtils.formatTime(parsed);
  }

  String? _normalizeId(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  String? _deriveLocationKey(Map<String, String>? location) {
    final campus = _normalizeId(location?['campus_id']);
    if (campus != null) {
      return 'campus:$campus';
    }
    final clinical = _normalizeId(location?['clinical_id']);
    if (clinical != null) {
      return 'clinical:$clinical';
    }
    final name = location?['name']?.trim().toLowerCase();
    if (name != null && name.isNotEmpty) {
      return 'name:$name';
    }
    return null;
  }
}

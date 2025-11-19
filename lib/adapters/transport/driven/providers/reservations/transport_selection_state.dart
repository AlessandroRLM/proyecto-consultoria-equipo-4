import 'package:intl/intl.dart';

class TransportSelectionState {
  static final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd');

  Map<String, String>? _location;
  String? _outboundTime;
  String? _returnTime;
  String? _outboundDate;
  String? _returnDate;
  String? _service;

  Map<String, String>? get location => _location;
  set location(Map<String, String>? value) => _location = value;

  String? get outboundTime => _outboundTime;
  set outboundTime(String? value) => _outboundTime = value;

  String? get returnTime => _returnTime;
  set returnTime(String? value) => _returnTime = value;

  String? get outboundDate => _outboundDate;
  void setOutboundDate(dynamic value) => _outboundDate = _normalizeDate(value);

  String? get returnDate => _returnDate;
  void setReturnDate(dynamic value) => _returnDate = _normalizeDate(value);

  String? get service => _service;
  set service(String? value) => _service = value;

  OutboundSelection? outboundSelection() {
    if (_location == null || _outboundTime == null || _outboundDate == null) {
      return null;
    }
    return OutboundSelection(
      date: _outboundDate!,
      location: _location!,
      time: _outboundTime!,
      service: _service,
    );
  }

  ReturnSelection? returnSelection() {
    if (_location == null || _returnTime == null || _returnDate == null) {
      return null;
    }
    return ReturnSelection(
      date: _returnDate!,
      location: _location!,
      time: _returnTime!,
      service: _service,
    );
  }

  RoundTripSelection? roundTripSelection() {
    if (_location == null ||
        _outboundTime == null ||
        _returnTime == null ||
        _outboundDate == null ||
        _returnDate == null) {
      return null;
    }
    return RoundTripSelection(
      location: _location!,
      outboundDate: _outboundDate!,
      returnDate: _returnDate!,
      outboundTime: _outboundTime!,
      returnTime: _returnTime!,
      service: _service,
    );
  }

  void clearReturnSelection() {
    _location = null;
    _returnTime = null;
    _returnDate = null;
    _service = null;
  }

  void clearAll() {
    _location = null;
    _outboundTime = null;
    _returnTime = null;
    _outboundDate = null;
    _returnDate = null;
    _service = null;
  }

  String? _normalizeDate(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is DateTime) {
      return _dateFormatter.format(value);
    }
    return value as String?;
  }
}

class OutboundSelection {
  const OutboundSelection({
    required this.date,
    required this.location,
    required this.time,
    this.service,
  });

  final String date;
  final Map<String, String> location;
  final String time;
  final String? service;
}

class ReturnSelection {
  const ReturnSelection({
    required this.date,
    required this.location,
    required this.time,
    this.service,
  });

  final String date;
  final Map<String, String> location;
  final String time;
  final String? service;
}

class RoundTripSelection {
  const RoundTripSelection({
    required this.location,
    required this.outboundDate,
    required this.returnDate,
    required this.outboundTime,
    required this.returnTime,
    this.service,
  });

  final Map<String, String> location;
  final String outboundDate;
  final String returnDate;
  final String outboundTime;
  final String returnTime;
  final String? service;
}

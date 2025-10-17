import 'estado_agenda.dart';

class AgendaModel {
  final int id;
  final int studentId;
  final String occupantName;
  final String occupantMobile;
  final String occupantKind; // "Interna" / "Externo"
  final String reservationDate; // "YYYY-MM-DD"
  final String reservationInit; // "HH:mm"
  final String reservationFin; // "HH:mm"
  final String clinicalName;
  final int homeId;
  final EstadoAgenda state;

  const AgendaModel({
    required this.id,
    required this.studentId,
    required this.occupantName,
    required this.occupantMobile,
    required this.occupantKind,
    required this.reservationDate,
    required this.reservationInit,
    required this.reservationFin,
    required this.clinicalName,
    required this.homeId,
    required this.state,
  });

  /// Combina fecha (YYYY-MM-DD) y hora (HH:mm) en un DateTime local.
  DateTime get startDateTime =>
      _combineDateTime(reservationDate, reservationInit);
  DateTime get endDateTime => _combineDateTime(reservationDate, reservationFin);

  static DateTime _combineDateTime(String date, String time) {
    // Asume zona local de la app; si necesitas UTC, agrega 'Z' y usa DateTime.parse.
    final partsDate = date.split('-').map(int.parse).toList(); // [yyyy, mm, dd]
    final partsTime = time.split(':').map(int.parse).toList(); // [HH, mm]
    return DateTime(
      partsDate[0],
      partsDate[1],
      partsDate[2],
      partsTime[0],
      partsTime[1],
    );
  }

  factory AgendaModel.fromJson(Map<String, dynamic> json) => AgendaModel(
    id: _toInt(json['id']),
    studentId: _toInt(json['student_id']),
    occupantName: (json['occupant_name'] ?? '').toString(),
    occupantMobile: (json['occupant_mobile'] ?? '').toString(),
    occupantKind: (json['occupant_kind'] ?? '').toString(),
    reservationDate: (json['reservation_date'] ?? '').toString(),
    reservationInit: (json['reservation_init'] ?? '').toString(),
    reservationFin: (json['reservation_fin'] ?? '').toString(),
    clinicalName: (json['clinical_name'] ?? '').toString(),
    homeId: _toInt(json['home_id']),
    state: EstadoAgendaX.fromJson((json['state'] ?? '').toString()),
  );
  // ---- helpers privados ----
  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim()) ?? 0;
    return 0;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'student_id': studentId,
    'occupant_name': occupantName,
    'occupant_mobile': occupantMobile,
    'occupant_kind': occupantKind,
    'reservation_date': reservationDate,
    'reservation_init': reservationInit,
    'reservation_fin': reservationFin,
    'clinical_name': clinicalName,
    'home_id': homeId,
    'state': state.toJson(),
  };
}

import 'dart:convert';

import 'vehicle_model.dart';
import 'driver_model.dart';
import 'gps_model.dart';

/// Agenda/Reserva de transporte para un estudiante en una fecha específica.
class TransportAgendaModel {
  final int agendaId;
  final String serviceName; // "Transporte Clínico"
  final DateTime date; // viene "dd-MM-yyyy"
  final String clinicalField; // nombre del campo clínico
  final String sede; // p.ej. "Santa Juana"
  final String tripType; // "ida" | "regreso"
  final String
  departureTime; // "HH:mm" (guardamos como string; opcionalmente parsear)
  final VehicleModel vehicle;
  final DriverModel? driver;
  final GpsPositionModel? gps;

  const TransportAgendaModel({
    required this.agendaId,
    required this.serviceName,
    required this.date,
    required this.clinicalField,
    required this.sede,
    required this.tripType,
    required this.departureTime,
    required this.vehicle,
    this.driver,
    this.gps,
  });

  /// dd-MM-yyyy -> DateTime (a medianoche local)
  static DateTime _parseDmy(String dmy) {
    final p = dmy.split('-').map(int.parse).toList(); // dd-MM-yyyy
    return DateTime(p[2], p[1], p[0]);
  }

  static String _formatDmy(DateTime d) {
    String two(int n) => n < 10 ? '0$n' : '$n';
    return '${two(d.day)}-${two(d.month)}-${d.year}';
  }

  factory TransportAgendaModel.fromJson(Map<String, dynamic> json) =>
      TransportAgendaModel(
        agendaId: json['agenda_id'] as int,
        serviceName: json['service_name'] as String,
        date: _parseDmy(json['date'] as String),
        clinicalField: json['clinical_field'] as String,
        sede: json['sede'] as String,
        tripType: json['trip_type'] as String,
        departureTime: json['departure_time'] as String,
        vehicle: VehicleModel.fromJson(json['vehicle'] as Map<String, dynamic>),
        driver: DriverModel.tryFromJson(
          json['driver'] as Map<String, dynamic>?,
        ),
        gps: GpsPositionModel.tryFromJson(json['gps'] as Map<String, dynamic>?),
      );

  Map<String, dynamic> toJson() => {
    'agenda_id': agendaId,
    'service_name': serviceName,
    'date': _formatDmy(date),
    'clinical_field': clinicalField,
    'sede': sede,
    'trip_type': tripType,
    'departure_time': departureTime,
    'vehicle': vehicle.toJson(),
    if (driver != null) 'driver': driver!.toJson(),
    if (gps != null) 'gps': gps!.toJson(),
  };

  static List<TransportAgendaModel> listFromJsonList(List<dynamic> list) => list
      .map((e) => TransportAgendaModel.fromJson(e as Map<String, dynamic>))
      .toList();

  static List<TransportAgendaModel> listFromRoot(Map<String, dynamic> root) =>
      listFromJsonList(root['agendas_en_curso'] as List<dynamic>);

  static List<TransportAgendaModel> listFromJsonString(String s) =>
      listFromRoot(jsonDecode(s) as Map<String, dynamic>);
}

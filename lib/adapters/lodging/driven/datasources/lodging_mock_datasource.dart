import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class LodgingMockDataSource {
  final String homesPath;
  final String scheduleStudentPath;
  final String schedulePath; //  NECESARIO para schedule.json

  LodgingMockDataSource({
    this.homesPath = 'assets/mocks/lodging/home.json',
    this.scheduleStudentPath = 'assets/mocks/lodging/schedule_student.json',
    this.schedulePath =
        'assets/mocks/lodging/schedule.json', //  valor por defecto
  });

  /// homes: puede venir como objeto único o lista
  Future<List<Map<String, dynamic>>> getHomesRaw() async {
    final raw = await rootBundle.loadString(homesPath);
    final decoded = json.decode(raw);
    if (decoded is List) return decoded.cast<Map<String, dynamic>>();
    if (decoded is Map<String, dynamic>) return [decoded];
    return const [];
  }

  /// agendas del estudiante
  Future<List<Map<String, dynamic>>> getStudentSchedulesRaw() async {
    final raw = await rootBundle.loadString(scheduleStudentPath);
    final decoded = json.decode(raw);
    if (decoded is List) return decoded.cast<Map<String, dynamic>>();
    return const [];
  }

  /// TODAS las agendas (excepto finalizadas en la lógica) — schedule.json
  Future<List<Map<String, dynamic>>> getSchedulesRaw() async {
    final raw = await rootBundle.loadString(schedulePath); //  usa el field
    final decoded = json.decode(raw);
    if (decoded is List) return decoded.cast<Map<String, dynamic>>();
    return const [];
  }
}

import 'dart:convert';

class LodgingReservationModel {
  final String area;
  final String name;
  final String address;
  final String room;
  final DateTime checkIn;
  final DateTime checkOut;

  const LodgingReservationModel({
    required this.area,
    required this.name,
    required this.address,
    required this.room,
    required this.checkIn,
    required this.checkOut,
  });

  static DateTime _parseDmy(String dmy) {
    // Soporta "dd/MM/yyyy" o "dd/MM" (usa año actual)
    final parts = dmy.replaceAll(RegExp(r'[A-Za-z\. ]'), '').split('/');
    final now = DateTime.now();
    final d = int.parse(parts[0]);
    final m = int.parse(parts[1]);
    final y = parts.length > 2 ? int.parse(parts[2]) : now.year;
    return DateTime(y, m, d);
  }

  static String _formatDmy(DateTime d) {
    String two(int n) => n < 10 ? '0$n' : '$n';
    return '${two(d.day)}/${two(d.month)}/${d.year}';
  }

  factory LodgingReservationModel.fromJson(Map<String, dynamic> json) =>
      LodgingReservationModel(
        area: json['area'] as String,
        name: json['name'] as String,
        address: json['address'] as String,
        room: json['room'] as String,
        checkIn: json['check_in'] is String
            ? _parseDmy(json['check_in'] as String)
            : DateTime.parse(json['check_in'] as String),
        checkOut: json['check_out'] is String
            ? _parseDmy(json['check_out'] as String)
            : DateTime.parse(json['check_out'] as String),
      );

  Map<String, dynamic> toJson() => {
    'area': area,
    'name': name,
    'address': address,
    'room': room,
    'check_in': _formatDmy(checkIn),
    'check_out': _formatDmy(checkOut),
  };

  static List<LodgingReservationModel> listFromJsonList(List<dynamic> list) =>
      list
          .map(
            (e) => LodgingReservationModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();

  static List<LodgingReservationModel> listFromJsonString(String s) =>
      listFromJsonList(jsonDecode(s) as List<dynamic>);
}

/// ViewModel que la UI (ReservationCard) consume para listar reservas.
/// Se arma a partir de los mocks: schedule_student.json + home.json.
class LodgingReservation {
  final String area; // clinical_name (campo clínico)
  final String name; // residenceName (nombre residencia)
  final String address; // address (dirección)
  final String room; // mock por ahora (no viene en JSON)
  final String checkIn; // "LUN 10/09" desde reservation_date
  final String checkOut; // simulación (reservation_date + 7 días)

  const LodgingReservation({
    required this.area,
    required this.name,
    required this.address,
    required this.room,
    required this.checkIn,
    required this.checkOut,
  });

  Map<String, dynamic> toJson() {
    return {
      'area': area,
      'name': name,
      'address': address,
      'room': room,
      'checkIn': checkIn,
      'checkOut': checkOut,
    };
  }

  factory LodgingReservation.fromJson(Map<String, dynamic> json) {
    return LodgingReservation(
      area: json['area'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      room: json['room'] as String,
      checkIn: json['checkIn'] as String,
      checkOut: json['checkOut'] as String,
    );
  }
}

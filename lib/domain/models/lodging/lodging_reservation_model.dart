/// ViewModel que la UI (ReservationCard) consume para listar reservas.
/// Se arma a partir de los mocks: schedule_student.json + home.json.
class LodgingReservation {
  final int homeId;
  final String area; // clinical_name (campo clínico)
  final String name; // residenceName (nombre residencia)
  final String address; // address (dirección)
  final String room; // mock por ahora (no viene en JSON)
  final String checkIn; // "LUN 10/09" desde reservation_date
  final String checkOut; // simulación (reservation_date + 7 días)

  const LodgingReservation({
    required this.homeId,
    required this.area,
    required this.name,
    required this.address,
    required this.room,
    required this.checkIn,
    required this.checkOut,
  });
}

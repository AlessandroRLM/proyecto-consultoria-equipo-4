import 'package:mobile/domain/core/campus.dart';

// Puerto para la persistencia de reservas de lodging.
abstract class ForPersistingReservations {
  /// Guarda una nueva reserva de alojamiento.
  Future<void> saveReservation(DateTime initDate, DateTime endDate, Campus campusId);
}
import 'package:mobile/domain/entities/transport_reservation_status.dart';

class TransportReservationStatusHelper {
  const TransportReservationStatusHelper();

  static String resolve(Map<String, dynamic> reservation) {
    final currentStatus = reservation['status'] as String?;
    if (currentStatus == TransportReservationStatus.aceptada.displayName) {
      final dateStr = reservation['date'] as String?;
      if (dateStr == null) {
        return TransportReservationStatus.pendiente.displayName;
      }
      final date = DateTime.tryParse(dateStr);
      if (date == null) {
        return TransportReservationStatus.pendiente.displayName;
      }
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final resDate = DateTime(date.year, date.month, date.day);
      if (resDate.isBefore(today)) {
        return TransportReservationStatus.finalizada.displayName;
      } else if (resDate.isAtSameMomentAs(today)) {
        return TransportReservationStatus.iniciada.displayName;
      } else {
        return TransportReservationStatus.aceptada.displayName;
      }
    }
    return currentStatus ?? TransportReservationStatus.pendiente.displayName;
  }
}

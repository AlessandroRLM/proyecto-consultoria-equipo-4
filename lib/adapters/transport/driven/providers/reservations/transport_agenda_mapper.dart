import 'package:intl/intl.dart';
import 'package:mobile/domain/entities/transport_reservation_status.dart';
import 'package:mobile/domain/models/transport/agenda_model.dart';

class TransportAgendaMapper {
  const TransportAgendaMapper();

  List<Map<String, dynamic>> mapAgendaToReservations(
    List<TransportAgendaModel> agenda,
  ) {
    final Map<String, Map<String, dynamic>> grouped = {};
    for (final item in agenda) {
      final key = item.agendaId.toString();
      final entry = grouped.putIfAbsent(
        key,
        () => {
          'id': key,
          'outbound': null,
          'return': null,
        },
      );
      final isOutbound = item.tripType.toLowerCase().contains('ida');
      final leg = _mapAgendaLeg(item, isOutbound: isOutbound);
      if (isOutbound) {
        entry['outbound'] = leg;
      } else {
        entry['return'] = leg;
      }
    }
    return grouped.values.toList();
  }

  Map<String, dynamic> _mapAgendaLeg(
    TransportAgendaModel agenda, {
    required bool isOutbound,
  }) {
    final origin = isOutbound ? agenda.sede : agenda.clinicalField;
    final destination = isOutbound ? agenda.clinicalField : agenda.sede;
    final detailTrip = isOutbound ? 'ida' : 'regreso';
    final dateStr = DateFormat('yyyy-MM-dd').format(agenda.date);
    return {
      'type': 'transport',
      'date': dateStr,
      'origin': origin,
      'destination': destination,
      'originAddress': origin,
      'destinationAddress': destination,
      'originTime': agenda.departureTime,
      'service': agenda.serviceName,
      'details': '$origin a $destination ($detailTrip)',
      'highlighted': true,
      'status': TransportReservationStatus.aceptada.displayName,
    };
  }
}

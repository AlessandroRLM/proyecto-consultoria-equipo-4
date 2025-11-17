import 'package:mobile/domain/models/transport/service_model.dart';
import 'package:mobile/ports/transport/driven/for_querying_transport.dart';
import 'package:mobile/ports/transport/drivers/for_transport_interactions.dart';

class TransportApplicationService {
  final ForQueryingTransport driven;
  final ForTransportInteractions driver;

  TransportApplicationService({
    required this.driven,
    required this.driver,
  });

  Future<void> loadStudentAgenda(TransportAgendaQuery query) async {
    try {
      final agenda = await driven.getStudentAgenda(query);
      driver.onAgendaLoaded(agenda);
    } catch (error) {
      driver.onTransportError(error);
    }
  }

  Future<void> loadServices(TransportServiceQuery query) async {
    try {
      final services = await driven.getServices(query);
      driver.onServicesLoaded(services);
    } catch (error) {
      driver.onTransportError(error);
    }
  }

  Future<void> createReservationForService({
  required TransportServiceModel service,
  required DateTime date,
}) async {
  try {
    final agenda = await driven.createReservation(
      serviceId: service.id,
      date: date,
    );
    driver.onReservationConfirmed(agenda);
  } catch (e) {
    driver.onTransportError(e);
  }
}

Future<void> cancelReservation(int agendaId) async {
  try {
    await driven.cancelReservation(agendaId);
    driver.onReservationCancelled(agendaId);
  } catch (e) {
    driver.onTransportError(e);
  }
}

}

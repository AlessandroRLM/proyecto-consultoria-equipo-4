import 'package:mobile/domain/models/transport/agenda_model.dart';
import 'package:mobile/domain/models/transport/service_model.dart';

/// Puerto driver para notificar/solicitar acciones desde la UI hacia la capa de aplicación.
abstract class ForTransportInteractions {
  /// Publica la agenda ya cargada para que la UI la muestre.
  void onAgendaLoaded(List<TransportAgendaModel> agenda);

  /// Publica la lista de servicios disponibles que coinciden con la búsqueda.
  void onServicesLoaded(List<TransportServiceModel> services);

  /// Notifica que se confirmó una reserva (ida, regreso o ambas).
  void onReservationConfirmed(TransportAgendaModel agenda);

  /// Notifica que una reserva se canceló correctamente.
  void onReservationCancelled(int agendaId);

  /// Notifica errores de negocio o de red.
  void onTransportError(Object error, [StackTrace? trace]);


  /// Solicita que se capture interacción para crear una reserva de ida.
  Future<void> requestOutboundReservation({
    required TransportServiceModel service,
    required DateTime date,
  });

  /// Solicita crear una reserva de regreso.
  Future<void> requestReturnReservation({
    required TransportServiceModel service,
    required DateTime date,
  });

  /// Solicita una reserva ida y vuelta en un solo paso.
  Future<void> requestRoundTripReservation({
    required TransportServiceModel outboundService,
    required TransportServiceModel returnService,
    required DateTime outboundDate,
    required DateTime returnDate,
  });

  /// Pide la cancelación de la reserva con id [agendaId].
  Future<void> requestReservationCancellation(int agendaId);
}

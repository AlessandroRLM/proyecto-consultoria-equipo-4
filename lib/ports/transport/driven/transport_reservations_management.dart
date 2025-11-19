// Puerto (interfaz) para gestión de reservas transporte.
abstract class TransportReservationsManagement {
  // Obtiene todas las reservas guardadas.
  Future<List<Map<String, dynamic>>> fetchReservations();
  // Guarda las reservas.
  Future<void> saveReservations(List<Map<String, dynamic>> reservations);

  // Obtiene las fechas en las que se puede hacer reservas.
  Future<List<DateTime>> getReservableDates(
    String clinicalId,
    DateTime startDate,
    int days,
  );

  // Obtiene los horarios disponibles para una fecha específica (ida o vuelta).
  Future<List<Map<String, dynamic>>> getAvailableSchedules(
    String date,
    bool isOutbound,
  );

  // Actualiza los estados de las reservas existentes.
  Future<List<Map<String, dynamic>>> fetchUpdatedReservations(
    List<Map<String, dynamic>> existingReservations,
  );

  // Reserva un tramo (ida o vuelta) para una fecha y hora específica.
  Future<bool> reserveLeg({
    required String date,
    required String time,
    required bool isOutbound,
    String? service,
    String? clinicalAddress,
    String? clinicalName,
  });

  // Cancela una reserva existente de un tramo (ida o vuelta).
  Future<bool> cancelLeg({
    required String date,
    required String time,
    required bool isOutbound,
  });

  // Verifica si existe una reserva de ida en una fecha.
  bool hasOutboundOnDate(String date);

  // Verifica si existe una reserva de vuelta en una fecha.
  bool hasReturnOnDate(String date);

  // Verifica si un horario específico ya está reservado.
  bool isOptionReserved(String date, String time, {bool isOutbound = true});

  // Obtiene todas las opciones de horarios para una fecha (reservadas o no).
  List<Map<String, dynamic>> getOptionsForDate(
    String dateStr, {
    bool isOutbound = true,
  });

  // Obtiene solo los horarios disponibles (sin reservar) para una fecha.
  List<Map<String, dynamic>> getAvailableOptionsForDate(
    String dateStr, {
    bool isOutbound = true,
  });

  // Verifica si una fecha tiene al menos un horario disponible.
  bool hasAvailableOptions(String dateStr);

  // Valida que el rango de fechas sea válido (start <= end).
  bool isValidRange(DateTime start, DateTime end);

  // Verifica si una fecha cumple las reglas de reserva (corte jueves).
  bool isWeekAllowed(DateTime date);

  // Obtiene la fecha mínima desde la cual se pueden hacer reservas.
  DateTime getMinReservableDate();

  // Obtiene el próximo día con horarios disponibles.
  String? getNextAvailableDate();
}

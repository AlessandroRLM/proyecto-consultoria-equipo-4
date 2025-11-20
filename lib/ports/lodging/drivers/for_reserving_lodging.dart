import 'package:mobile/domain/core/campus.dart';

abstract class ForReservingLodging {
  /// El campus para el cuál sera reservado el alojamiento.
  Campus? get campus;
  set campus(Campus? campus);

  /// La fecha de inicio para la cual se desea reservar el alojamiento.
  DateTime? get initDate;
  set initDate(DateTime? initDate);

  /// La fecha de fin para la cual se desea reservar el alojamiento.
  DateTime? get endDate;
  set endDate(DateTime? endDate);

  /// Reserva el alojamiento para el campus con el id [campusId] en el rango de fechas [initDate] a [endDate].
  Future<void> reserveLodging(DateTime initDate, DateTime endDate, Campus campusId);

  /// Retorna la fecha minima para la cual se puede reservar el alojamiento.
  DateTime getMinReservableDate();
}
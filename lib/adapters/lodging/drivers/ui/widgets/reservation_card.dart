import 'package:flutter/material.dart';
import 'package:mobile/adapters/core/driven/app_themes.dart';
import 'package:mobile/adapters/core/drivers/ui/widgets/status_widget.dart';
import 'package:mobile/domain/models/lodging/agenda_model.dart';
import 'package:go_router/go_router.dart';

class ReservationCard extends StatefulWidget {
  final AgendaModel reservation;
  const ReservationCard({super.key, required this.reservation});

  @override
  State<ReservationCard> createState() => _ReservationCardState();
}

class _ReservationCardState extends State<ReservationCard> {
  bool expanded = false;

  /// Formatea solo la **fecha de reserva** (YYYY-MM-DD) a algo más legible.
  String _formatReservationDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      const weekdays = [
        'Lunes',
        'Martes',
        'Miércoles',
        'Jueves',
        'Viernes',
        'Sábado',
        'Domingo',
      ];
      const months = [
        'Enero',
        'Febrero',
        'Marzo',
        'Abril',
        'Mayo',
        'Junio',
        'Julio',
        'Agosto',
        'Septiembre',
        'Octubre',
        'Noviembre',
        'Diciembre',
      ];
      final weekday = weekdays[date.weekday - 1];
      final day = date.day;
      final month = months[date.month - 1];
      final year = date.year;
      return "$weekday $day de $month $year";
    } catch (_) {
      // Si viniera algo raro, mostramos el string tal cual
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => setState(() => expanded = !expanded),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: AppThemes.black_500.withValues(alpha: 0.4),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER: icono + nombre + estado + fecha de reserva
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.home_outlined, size: 32, color: cs.primary),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                widget.reservation.clinicalName,
                                style: text.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            StatusWidget(estado: widget.reservation.state.name),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          // aquí seteamos/ formateamos la fecha
                          "Reserva: ${_formatReservationDate(widget.reservation.reservationDate)}",
                          style: text.bodySmall?.copyWith(
                            color: text.bodySmall?.color?.withValues(
                              alpha: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (expanded) ...[
                const Divider(height: 24, thickness: 1),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            // horas tal cual, sin parsear
                            "Entrada: ${widget.reservation.reservationInit}",
                            style: text.bodyMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Salida: ${widget.reservation.reservationFin}",
                            style: text.bodyMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Habitación: ${widget.reservation.occupantKind}",
                            style: text.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        context.go(
                          '/lodging/detail/${widget.reservation.homeId}',
                        );
                      },

                      child: const Text("Ver"),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

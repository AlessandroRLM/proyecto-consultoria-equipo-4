import 'package:flutter/material.dart';
import 'package:mobile/adapters/core/driven/app_themes.dart';
import 'package:mobile/adapters/lodging/driven/providers/lodging_provider.dart';
import 'package:provider/provider.dart';

class ReservationCard extends StatefulWidget {
  final LodgingReservation reservation;
  const ReservationCard({super.key, required this.reservation});

  @override
  State<ReservationCard> createState() => _ReservationCardState();
}

class _ReservationCardState extends State<ReservationCard> {
  bool expanded = false;

  String _formatDateFull(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final weekdays = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
      final months = [
        'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
        'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
      ];
      final weekday = weekdays[date.weekday - 1];
      final day = date.day;
      final month = months[date.month - 1];
      return "$weekday $day de $month";
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final lodgingProvider = Provider.of<LodgingProvider>(context, listen: false);
    final clinicInfo = lodgingProvider.getClinicInfoByName(widget.reservation.area);
    final city = clinicInfo != null ? clinicInfo["city"] : null;
    final address = clinicInfo != null ? clinicInfo["address"] : widget.reservation.address;

    return GestureDetector(
      onTap: () {
        setState(() {
          expanded = !expanded;
        });
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: expanded ? 4 : 0,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        color: expanded ? null : cs.surface,
        child: Container(
          decoration: expanded
              ? null
              : BoxDecoration(
                  border: Border.all(color: cs.outline),
                  borderRadius: BorderRadius.circular(12),
                ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.home,
                    size: 28,
                    color: AppThemes.primary_600,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          city != null ? "${widget.reservation.area} - $city." : widget.reservation.area,
                          style: text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          address ?? '',
                          style: text.bodySmall?.copyWith(color: text.bodySmall?.color?.withValues(alpha: 0.7)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (expanded) ...[
                const Divider(height: 20, thickness: 1),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Entrada: ${_formatDateFull(widget.reservation.checkIn)}",
                            style: text.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Salida: ${_formatDateFull(widget.reservation.checkOut)}",
                            style: text.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Habitación: ${widget.reservation.room.isNotEmpty ? widget.reservation.room : 'PRA-322'}",
                            style: text.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        textStyle: text.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('El mapa aún no está implementado.')),
                        );
                      },
                      child: const Text("Mapa"),
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

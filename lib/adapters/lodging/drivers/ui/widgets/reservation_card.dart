import 'package:flutter/material.dart';
import 'package:mobile/adapters/core/driven/app_themes.dart';
import 'package:mobile/adapters/lodging/driven/providers/lodging_provider.dart';
import 'package:provider/provider.dart';
import 'package:mobile/domain/models/lodging/lodging_reservation_model.dart';

class ReservationCard extends StatefulWidget {
  final LodgingReservation reservation;
  const ReservationCard({super.key, required this.reservation});

  @override
  State<ReservationCard> createState() => _ReservationCardState();
}

class _ReservationCardState extends State<ReservationCard> {
  bool expanded = false;
  Map<String, String>? clinicInfo;

  @override
  void initState() {
    super.initState();
    _loadClinicInfo();
  }

  Future<void> _loadClinicInfo() async {
    final lodgingProvider = Provider.of<LodgingProvider>(context, listen: false);
    clinicInfo = await lodgingProvider.getClinicInfoByName(widget.reservation.area);
    if (mounted) setState(() {});
  }

  String _formatDateFull(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      const weekdays = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
      const months = [
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
    final city = clinicInfo?['city'] ?? 'No disponible...';
    final commune = clinicInfo?['commune'] ?? 'No disponible...';

    return GestureDetector(
      onTap: () {
        setState(() {
          expanded = !expanded;
        });
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppThemes.black_500.withValues(alpha: 0.4)),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.home_outlined,
                    size: 32,
                    color: cs.primary,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.reservation.area, 
                          style: text.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),

                        Text(
                          city,
                          style: text.bodyMedium?.copyWith(
                            color: text.bodyMedium?.color?.withValues(alpha: 0.8),
                          ),
                        ),

                        Text(
                          commune,
                          style: text.bodyMedium?.copyWith(
                            color: text.bodyMedium?.color?.withValues(alpha: 0.8),
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
                            "Entrada: ${_formatDateFull(widget.reservation.checkIn)}",
                            style: text.bodyMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Salida: ${_formatDateFull(widget.reservation.checkOut)}",
                            style: text.bodyMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Habitación: ${widget.reservation.room}",
                            style: text.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No implementada.')),
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
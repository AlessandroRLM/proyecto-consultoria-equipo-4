import 'package:flutter/material.dart';
import 'package:mobile/adapters/core/driven/app_themes.dart';
import 'package:mobile/adapters/lodging/driven/providers/lodging_provider.dart';
import 'package:mobile/domain/models/lodging/agenda_model.dart';
import 'package:provider/provider.dart';

class ReservationCard extends StatefulWidget {
  final AgendaModel agenda;
  const ReservationCard({super.key, required this.agenda});

  @override
  State<ReservationCard> createState() => _ReservationCardState();
}

class _ReservationCardState extends State<ReservationCard> {
  bool expanded = false;

  String _fmtDate(String ymd) {
    try {
      final d = DateTime.parse(ymd);
      const days = ['LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB', 'DOM'];
      return '${days[d.weekday - 1]} ${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
    } catch (_) {
      return ymd;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final home = context.read<LodgingProvider>().getHomeById(
      widget.agenda.homeId,
    );
    final residenceName = home?.residenceName ?? 'Residencia';
    final address = home?.address ?? '';

    return InkWell(
      onTap: () => setState(() => expanded = !expanded),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.cottage_outlined,
                  size: 28,
                  color: AppThemes.primary_600,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.agenda.clinicalName,
                        style: text.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(residenceName, style: text.bodyMedium),
                      Text(address, style: text.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            if (expanded) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Entrada: ${_fmtDate(widget.agenda.reservationDate)}",
                    style: text.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Salida: ${_fmtDate(widget.agenda.reservationDate)}",
                    style: text.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Habitación: ${widget.agenda.homeId}",
                    style: text.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

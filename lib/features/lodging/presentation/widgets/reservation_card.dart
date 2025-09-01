import 'package:flutter/material.dart';
import 'package:mobile/features/lodging/providers/lodging_provider.dart';
import 'package:mobile/adapter/core/out/app_themes.dart'; // Para AppThemes.primary_600

class ReservationCard extends StatefulWidget {
  final LodgingReservation reservation;
  const ReservationCard({super.key, required this.reservation});

  @override
  State<ReservationCard> createState() => _ReservationCardState();
}

class _ReservationCardState extends State<ReservationCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final leftInfo = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.reservation.area,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        Text(widget.reservation.name),
        Text(widget.reservation.address),
      ],
    );

    final midExtra = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Habitación: ${widget.reservation.room}"),
        Text("Entrada: ${widget.reservation.checkIn}"),
        Text("Salida: ${widget.reservation.checkOut}"),
      ],
    );

    return InkWell(
      onTap: () => setState(() => expanded = !expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[400]!),
        ),
        child: expanded
            ? Row(
                children: [
                  Expanded(child: leftInfo),
                  const SizedBox(width: 8),
                  Expanded(child: midExtra),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.house_rounded,
                    size: 28,
                    color: AppThemes.primary_600,
                  ),
                ],
              )
            : Row(
                children: [
                  Icon(
                    Icons.house_rounded,
                    size: 28,
                    color: AppThemes.primary_600,
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: leftInfo),
                ],
              ),
      ),
    );
  }
}

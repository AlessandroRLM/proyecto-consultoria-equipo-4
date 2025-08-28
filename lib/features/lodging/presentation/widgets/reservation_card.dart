import 'package:flutter/material.dart';
import 'package:mobile/features/lodging/providers/lodging_provider.dart';
import 'package:intl/intl.dart';

class ReservationCard extends StatelessWidget {
  final LodgingReservation reservation;

  const ReservationCard({super.key, required this.reservation});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              reservation.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(reservation.address),
            const SizedBox(height: 6),
            Text("Entrada: ${dateFormat.format(reservation.startDate)}"),
            Text("Salida: ${dateFormat.format(reservation.endDate)}"),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/adapters/lodging/driven/providers/lodging_provider.dart';
import 'package:mobile/adapters/lodging/drivers/ui/widgets/reservation_card.dart';
import 'package:provider/provider.dart';

class LodgingListScreen extends StatelessWidget {
  const LodgingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reservations = context.watch<LodgingProvider>().reservations;

    return Scaffold(
      body: Padding(
        padding: EdgeInsetsGeometry.fromLTRB(8, 0, 16, 0),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 12, bottom: 12),
            child: Text('Reservas', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w500),),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: reservations.isEmpty
              ? Center(
                  child: Text(
                    'Aún no hay reservas disponibles.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).disabledColor,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsetsGeometry.fromLTRB(0, 0, 0, 0),
                  itemCount: reservations.length,
                  itemBuilder: (context, index) {
                    final reservation = reservations[index];
                    return ReservationCard(reservation: reservation);
                  },
                ),)
        ],
    ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/lodging/new'),
        label: const Text("Reservar"),
        icon: const Icon(Icons.calendar_today),
      ),
    );
  }
}

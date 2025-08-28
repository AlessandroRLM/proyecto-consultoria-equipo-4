import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/lodging/providers/lodging_provider.dart';
import 'package:mobile/features/lodging/presentation/widgets/reservation_card.dart';
import 'package:provider/provider.dart';

class LodgingListScreen extends StatelessWidget {
  const LodgingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reservations = context.watch<LodgingProvider>().reservations;

    return Scaffold(
      appBar: AppBar(title: const Text('Reservas')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: reservations.isEmpty
            ? const Center(child: Text("No hay reservas aún"))
            : ListView.builder(
                itemCount: reservations.length,
                itemBuilder: (context, index) =>
                    ReservationCard(reservation: reservations[index]),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/lodging/new'),
        label: const Text("Reservar"),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

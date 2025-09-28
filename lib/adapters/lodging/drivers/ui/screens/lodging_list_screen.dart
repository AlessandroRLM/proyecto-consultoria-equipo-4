import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/adapters/lodging/driven/providers/lodging_provider.dart';
import 'package:mobile/adapters/lodging/drivers/ui/widgets/reservation_card.dart';
import 'package:provider/provider.dart';

class LodgingListScreen extends StatelessWidget {
  const LodgingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LodgingProvider>();
    final reservations = provider.reservations;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Reservas',
              style: TextStyle(fontSize: 27, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),

            if (provider.loading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (provider.error != null)
              Expanded(
                child: Center(
                  child: Text(
                    "Error: ${provider.error}",
                    style: TextStyle(color: cs.error),
                  ),
                ),
              )
            else
              Expanded(
                child: reservations.isEmpty
                    ? Center(
                        child: Text(
                          "No hay reservas aún",
                          style: TextStyle(color: cs.onSurfaceVariant),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: reservations.length,
                        itemBuilder: (context, index) =>
                            ReservationCard(reservation: reservations[index]),
                      ),
              ),
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

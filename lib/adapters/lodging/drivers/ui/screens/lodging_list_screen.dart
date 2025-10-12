import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/adapters/core/drivers/ui/layouts/base_screen_layout.dart';
import 'package:mobile/adapters/lodging/driven/providers/lodging_provider.dart';
import 'package:mobile/adapters/lodging/drivers/ui/widgets/reservation_card.dart';
import 'package:provider/provider.dart';

class LodgingListScreen extends StatefulWidget {
  const LodgingListScreen({super.key});

  @override
  State<LodgingListScreen> createState() => _LodgingListScreenState();
}

class _LodgingListScreenState extends State<LodgingListScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LodgingProvider>();
    final reservations = provider.reservations;
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BaseScreenLayout(
      title: "Reservas",
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/clinic_selection/2'),
        label: Text(
          "Reservar",
          style: textTheme.titleMedium!.copyWith(color: cs.onPrimary),
        ),
        icon: const Icon(Icons.calendar_today),
        heroTag: 'reserve_lodging_button',
      ),
      child: Column(
        children: [
          if (provider.loading)
            const Center(child: CircularProgressIndicator())
          else if (provider.error != null)
            Center(
              child: Text(
                "Error: ${provider.error}",
                style: TextStyle(color: cs.error),
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
    );
  }
}

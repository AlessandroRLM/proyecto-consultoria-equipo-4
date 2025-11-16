import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/adapters/core/drivers/ui/layouts/base_screen_layout.dart';
import 'package:mobile/adapters/core/drivers/ui/widgets/request_button.dart';
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
    final reservations = provider.userReservations;
    final theme = Theme.of(context);

    return BaseScreenLayout(
      title: 'Reservas',
      floatingActionButton: RequestButton(
        function: () => context.go('/lodging/new'),
        label: 'Reservar',
        icon: Icons.calendar_today,
        heroTag: 'lodging_request_button',
      ),
      child: Column(
        children: [
          if (provider.loading)
            const Center(child: CircularProgressIndicator())

          else if (provider.error != null)
            Center(
              child: Text(
                "Error: ${provider.error}",
                style: TextStyle(color: theme.colorScheme.error),
              ),
            )

          else
            Expanded(
              child: reservations.isEmpty
                  ? Center(
                      child: Text(
                        // Combinación de ambos textos originales
                        'No hay reservas aún.\nAún no hay reservas disponibles.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.disabledColor,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 8.0), // de main
                      itemCount: reservations.length,
                      itemBuilder: (context, index) =>
                          ReservationCard(reservation: reservations[index]),
                    ),
            )
        ],
      ),
    );
  }
}

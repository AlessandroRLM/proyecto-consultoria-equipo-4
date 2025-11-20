import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:mobile/adapters/core/drivers/ui/layouts/base_screen_layout.dart';
import 'package:mobile/adapters/core/drivers/ui/widgets/request_button.dart';
import 'package:mobile/adapters/lodging/drivers/ui/widgets/reservation_card.dart';
import 'package:mobile/adapters/lodging/drivers/providers/lodging_provider.dart';

class LodgingListScreen extends StatelessWidget {
  const LodgingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BaseScreenLayout(
      title: 'Reservas',
      floatingActionButton: RequestButton(
        function: () async {
          await context.push('/lodging/new');
          // Refrescar después de crear una reserva
          if (context.mounted) {
            context.read<LodgingProvider>().refresh();
          }
        },
        label: 'Reservar',
        icon: Icons.calendar_today,
        heroTag: 'lodging_request_button',
      ),
      child: Consumer<LodgingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    provider.error!,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.refresh(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (provider.reservations.isEmpty) {
            return Center(
              child: Text(
                'Aún no hay reservas disponibles.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.disabledColor,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8.0),
              itemCount: provider.reservations.length,
              itemBuilder: (context, index) {
                final reservation = provider.reservations[index];
                return ReservationCard(reservation: reservation);
              },
            ),
          );
        },
      ),
    );
  }
}
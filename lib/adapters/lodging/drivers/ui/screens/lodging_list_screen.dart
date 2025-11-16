import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/adapters/core/drivers/ui/layouts/base_screen_layout.dart';
import 'package:mobile/adapters/core/drivers/ui/widgets/request_button.dart';
import 'package:mobile/adapters/lodging/driven/providers/lodging_provider.dart';
import 'package:mobile/adapters/lodging/drivers/ui/widgets/reservation_card.dart';
import 'package:provider/provider.dart';

class LodgingListScreen extends StatelessWidget {
  const LodgingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reservations = context.watch<LodgingProvider>().userReservations;
    final theme = Theme.of(context);

    return BaseScreenLayout(
      title: 'Reservas',
      floatingActionButton: RequestButton(
        function: () => context.go('/lodging/new'),
        label: 'Reservar',
        icon: Icons.calendar_today,
        heroTag: 'lodging_request_button',
      ),
      child: reservations.isEmpty
          ? Center(
              child: Text(
                'Aún no hay reservas disponibles.',
                style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.disabledColor,
                    ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8.0), 
              itemCount: reservations.length,
              itemBuilder: (context, index) {
                final reservation = reservations[index];
                return ReservationCard(reservation: reservation);
              },
            ),
    );
  }
}
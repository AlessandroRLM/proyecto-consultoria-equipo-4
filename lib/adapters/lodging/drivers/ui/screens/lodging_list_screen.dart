import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/adapters/core/drivers/ui/layouts/base_screen_layout.dart';
import 'package:mobile/adapters/core/drivers/ui/widgets/request_button.dart';
import 'package:mobile/adapters/lodging/drivers/ui/widgets/reservation_card.dart';
import 'package:mobile/ports/lodging/driven/for_querying_lodging.dart';
import 'package:mobile/service_locator.dart';
import 'package:mobile/domain/models/lodging/agenda_model.dart';

class LodgingListScreen extends StatelessWidget {
  const LodgingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lodgingService = serviceLocator<ForQueryingLodging>();

    return BaseScreenLayout(
      title: 'Reservas',
      floatingActionButton: RequestButton(
        function: () => context.go('/lodging/new'),
        label: 'Reservar',
        icon: Icons.calendar_today,
        heroTag: 'lodging_request_button',
      ),

      // getStudentAgendas()
      child: FutureBuilder<List<AgendaModel>>(
        future: lodgingService.getStudentAgendas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Ocurrió un error al cargar las reservas.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }

          final reservations = snapshot.data ?? const <AgendaModel>[];

          if (reservations.isEmpty) {
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

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8.0),
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              final reservation = reservations[index];
              return ReservationCard(reservation: reservation);
            },
          );
        },
      ),
    );
  }
}

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
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Padding(
        padding: EdgeInsetsGeometry.fromLTRB(16, 0, 16, 0),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reservas', style: textTheme.displayMedium,),
          const SizedBox(height: 8),
          Expanded(
            child: reservations.isEmpty
              ? Center(
                  child: Text(
                    "No hay reservas aún",
                    style: textTheme.displaySmall
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsetsGeometry.fromLTRB(0, 0, 0, 0),
                  itemCount: reservations.length,
                  itemBuilder: (context, index) =>
                      ReservationCard(reservation: reservations[index]),
                ),)
        ],
    ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/clinic_selection/2'),
        label: Text("Reservar", style: textTheme.titleMedium!.copyWith(
          color: cs.onPrimary,
        ),),
        icon: const Icon(Icons.calendar_today),
        heroTag: 'reserve_lodging_button',
      ),
    );
  }
}

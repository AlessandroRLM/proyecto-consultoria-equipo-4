import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/adapter/lodging/drivens/providers/lodging_provider.dart';
import 'package:mobile/adapter/lodging/drivers/ui/widgets/reservation_card.dart';
import 'package:provider/provider.dart';
import 'package:mobile/adapter/lodging/drivers/ui/widgets/calendar_icon_button.dart';

class LodgingListScreen extends StatelessWidget {
  const LodgingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reservations = context.watch<LodgingProvider>().reservations;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservas'),
        actions: [
          CalendarIconButton(
            onDateSelected: (selectedDate) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Fecha seleccionada: ${selectedDate.toLocal()}'.split(
                      ' ',
                    )[0],
                  ),
                ),
              );
            },
          ), //CALENDARIO SOLO A MODO DE PRUEBA
        ],
      ),
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
        icon: const Icon(Icons.calendar_today),
      ),
    );
  }
}

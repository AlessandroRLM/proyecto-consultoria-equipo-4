import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/adapters/core/drivers/ui/layouts/base_screen_layout.dart';
import 'package:mobile/adapters/core/drivers/ui/widgets/request_button.dart';
import 'package:mobile/adapters/transport/driven/providers/transport_reservations_provider.dart';
import 'package:provider/provider.dart';

class TransportScreen extends StatefulWidget {
  const TransportScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TransportScreenState createState() => _TransportScreenState();
}

class _TransportScreenState extends State<TransportScreen> {
  // CustomTabBar Credencial, Transporte y Alojamiento.

  Widget buildHighlightedReservationCard(Map<String, dynamic> reservation) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reservation['origin'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    reservation['originTime'],
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
              Column(
                children: [
                  const Icon(Icons.directions_bus, color: Colors.red, size: 20),
                  Text(
                    reservation['date'],
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    reservation['destination'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    reservation['destinationTime'],
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildSimpleReservationCard(Map<String, dynamic> reservation) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.directions_bus, color: Colors.red, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reservation['route'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  reservation['time'],
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
 
  @override
  Widget build(BuildContext context) {
    return BaseScreenLayout(
      title: "Reservas",
      floatingActionButton: RequestButton(
        function: () => context.push('/clinic_selection/1'),
        label: 'Reservar',
        icon: Icons.calendar_today,
        heroTag: 'reserve_transport_button',
      ),
      child: Consumer<TransportReservationsProvider>(
        builder: (context, provider, child) {
          final reservations = provider.reservations;
          if (reservations.isEmpty) {
            return const Center(
              child: Text(
                'Aún no hay reservas disponibles.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }
          return ListView.builder(
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              final reservation = reservations[index];
              if (reservation['highlighted'] == true) {
                return buildHighlightedReservationCard(reservation);
              } else {
                return buildSimpleReservationCard(reservation);
              }
            },
          );
        },
      ),
    );
  }
}

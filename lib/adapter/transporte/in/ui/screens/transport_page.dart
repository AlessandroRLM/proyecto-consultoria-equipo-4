import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../out/providers/transport_reservations_provider.dart';
import 'reservation_page.dart';
import 'transport_calendar_screen.dart';

class TransportPage extends StatefulWidget {
  const TransportPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TransportPageState createState() => _TransportPageState();
}

class _TransportPageState extends State<TransportPage> {
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.red),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CustomTabBar Credencial, Transporte y Alojamiento.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Reservas',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const TransportCalendarScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red, width: 2),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    child: const Icon(Icons.calendar_today, color: Colors.red, size: 20),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ReservationPage(showMapButton: true),
            ),
          );
        },
        label: const Text('Reservar', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.calendar_today, color: Colors.white),
        backgroundColor: Colors.red,
      ),
    );
  }
}

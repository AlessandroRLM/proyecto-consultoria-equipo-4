import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/adapters/core/drivers/ui/layouts/base_screen_layout.dart';
import 'package:mobile/adapters/core/drivers/ui/widgets/request_button.dart';
import 'package:mobile/adapters/transport/drivers/ui/widgets/transport_reservation_card.dart';
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

<<<<<<< HEAD
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransportReservationsProvider>(context, listen: false).fetchReservations();
    });
=======
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
>>>>>>> origin/main
  }

  List<Map<String, dynamic>> getGroupedReservations(List<Map<String, dynamic>> reservations) {
    final sortedReservations = List<Map<String, dynamic>>.from(reservations);

    int compareReservations(Map<String, dynamic> a, Map<String, dynamic> b) {
      DateTime parseDateTime(String? dateStr, String? timeStr) {
        if (dateStr == null || timeStr == null) {
          return DateTime(2100); 
        }
        try {
          final date = DateTime.parse(dateStr);
          final timeParts = timeStr.split(':');
          int hour = 0;
          int minute = 0;
          if (timeParts.length >= 2) {
            hour = int.tryParse(timeParts[0]) ?? 0;
            minute = int.tryParse(timeParts[1]) ?? 0;
          }
          return DateTime(date.year, date.month, date.day, hour, minute);
        } catch (e) {
          return DateTime(2100);
        }
      }

      final dateA = a['date'] as String?;
      final timeA = a['originTime'] as String?;
      final dateB = b['date'] as String?;
      final timeB = b['originTime'] as String?;

      final dateTimeA = parseDateTime(dateA, timeA);
      final dateTimeB = parseDateTime(dateB, timeB);

      final dateCompare = dateTimeA.compareTo(dateTimeB);
      if (dateCompare != 0) {
        return dateCompare;
      }

      final detailsA = (a['details'] as String?)?.toLowerCase() ?? '';
      final detailsB = (b['details'] as String?)?.toLowerCase() ?? '';

      if (detailsA.contains('ida') && detailsB.contains('regreso')) {
        return -1;
      } else if (detailsA.contains('regreso') && detailsB.contains('ida')) {
        return 1;
      }
      return dateTimeA.compareTo(dateTimeB);
    }

    sortedReservations.sort(compareReservations);

    return sortedReservations;
  }
<<<<<<< HEAD


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservas'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Consumer<TransportReservationsProvider>(
              builder: (context, provider, child) {
                final reservations = provider.futureReservations;
                if (reservations.isEmpty) {
                  return Center(
                    child: Text(
                      'Aún no hay reservas disponibles.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.disabledColor,
                      ),
                    ),
                  );
                }
                final grouped = getGroupedReservations(reservations);
                return ListView.builder(
                  itemCount: grouped.length,
                  itemBuilder: (context, index) {
                    final reservation = grouped[index];
                    return TransportReservationCard(reservation: reservation);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: RequestButton(
        funcion: () => context.push('/transport/reservation/location-search'),
        label: 'Reservar',
        icon: Icons.calendar_today,
      ),
      
=======
 
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
>>>>>>> origin/main
    );
  }
}

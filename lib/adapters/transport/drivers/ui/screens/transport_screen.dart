import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransportReservationsProvider>(context, listen: false).fetchReservations();
    });
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
      
    );
  }
}

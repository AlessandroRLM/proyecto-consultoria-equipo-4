import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransportReservationsProvider>(context, listen: false).fetchReservations();
    });
  }

  void _showReservationDetailsDialog(BuildContext context, dynamic reservation) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Detalles de la Reserva'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: _buildDialogContent(reservation),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildDialogContent(Map<String, dynamic> reservation) {
    final origin = reservation['origin'] as String? ?? 'Origen no disponible';
    final destination = reservation['destination'] as String? ?? 'Destino no disponible';
    final originTime = reservation['originTime'] as String? ?? 'Hora no disponible';
    final service = reservation['service'] as String? ?? 'Servicio no disponible';
    final date = reservation['date'] as String?;
    final formattedDate = date != null ? formatDate(DateTime.parse(date)) : 'Fecha no disponible';
    final details = reservation['details'] as String? ?? 'Detalles no disponibles';
    final isReturn = details.toLowerCase().contains('regreso');
    final isOutbound = details.toLowerCase().contains('ida');
    final tipo = isReturn ? 'REGRESO' : (isOutbound ? 'IDA' : 'Desconocido');

    return [
      Text('Tipo: $tipo'),
      Text('Origen: $origin'),
      Text('Destino: $destination'),
      Text('Fecha: $formattedDate'),
      Text('Hora de salida: ${formatTime(originTime)}'),
      Text('Servicio: $service'),
      Text('Detalles: $details'),
    ];
  }

  String getDisplayLocation(String? location) {
    if (location == null) return 'Desconocido';
    switch (location) {
      case 'Campus Universitario':
        return 'Campus Universidad';
      case 'Campo Clínico':
        return 'Campo Clínico';
      default:
        return location;
    }
  }

  String formatDate(dynamic date) {
    if (date == null) return 'Fecha no disponible';
    DateTime parsedDate;
    if (date is DateTime) {
      parsedDate = date;
    } else if (date is String) {
      try {
        parsedDate = DateTime.parse(date);
      } catch (e) {
        return 'Fecha inválida';
      }
    } else {
      return 'Fecha inválida';
    }
    return DateFormat('EEE dd/MM', 'es_ES').format(parsedDate);
  }

  String formatTime(String? timeStr) {
    if (timeStr == null) return 'Hora no disponible';
    try {
      final timeParts = timeStr.split(':');
      if (timeParts.length == 2) {
        final second = timeParts[1];
        final ampmMatch = RegExp(r'(am|pm)', caseSensitive: false).firstMatch(second);
        int hour = 0;
        int minute = 0;
        String ampm = '';
        if (ampmMatch != null) {
          ampm = ampmMatch.group(0)!.toUpperCase();
          final minuteStr = second.substring(0, ampmMatch.start).trim();
          minute = int.tryParse(minuteStr) ?? 0;
          hour = int.tryParse(timeParts[0]) ?? 0;
          if (ampm.toLowerCase() == 'pm' && hour < 12) {
            hour += 12;
          } else if (ampm.toLowerCase() == 'am' && hour == 12) {
            hour = 0;
          }
        } else {
          hour = int.tryParse(timeParts[0]) ?? 0;
          minute = int.tryParse(second) ?? 0;
          ampm = hour >= 12 ? 'PM' : 'AM';
        }
        return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $ampm';
      }
      return timeStr; 
    } catch (e) {
      return timeStr; 
    }
  }


  Widget buildHighlightedReservationCard(Map<String, dynamic> reservation) {
    final theme = Theme.of(context);
    final origin = reservation['origin'] as String? ?? 'Origen no disponible';
    final destination = reservation['destination'] as String? ?? 'Destino no disponible';
    final originTime = reservation['originTime'] as String? ?? 'Hora no disponible';
    final date = reservation['date'] as String?;
    final formattedDate = date != null ? formatDate(DateTime.parse(date)) : 'Fecha no disponible';
    final details = reservation['details'] as String? ?? '';
    final isReturn = details.toLowerCase().contains('regreso');
    final isOutbound = details.toLowerCase().contains('ida');

    return InkWell(
      onTap: () => _showReservationDetailsDialog(context, reservation),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor),
            color: theme.cardColor,
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: 0.15),
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.directions_bus, color: Colors.red, size: 28),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                        children: [
                          Expanded(
                            child: Text(
                              getDisplayLocation(origin),
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(Icons.arrow_forward, size: 18, color: Colors.grey),
                          ),
                          Expanded(
                            child: Text(
                              getDisplayLocation(destination),
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),

                  Text(
                    '$formattedDate - ${formatTime(originTime)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CustomTabBar Credencial, Transporte y Alojamiento.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              'Reservas',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
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
                    return buildHighlightedReservationCard(reservation);
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

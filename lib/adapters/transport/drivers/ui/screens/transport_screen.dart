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

  String getDisplayLocation(String? location) {
    if (location == null) return 'Desconocido';
    switch (location) {
      case 'Santiago':
        return 'Universidad';
      case 'Concepción':
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


  Widget buildHighlightedReservationCard(Map<String, dynamic> reservation) {
    final theme = Theme.of(context);
    final origin = reservation['origin'] as String? ?? 'N/A';
    final dest = reservation['destination'] as String? ?? 'N/A';
    final originTime = reservation['originTime'] as String? ?? '';
    final destTime = reservation['destinationTime'] as String? ?? '';
    final displayOrigin = getDisplayLocation(origin);
    final displayDest = getDisplayLocation(dest);
    final formattedDate = formatDate(reservation['date']);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayOrigin,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Text(
                      originTime,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              Container(
                width: 80,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.directions_bus, color: Colors.red, size: 24),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      displayDest,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Text(
                      destTime,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildRoundTripCard(Map<String, dynamic> outbound, Map<String, dynamic> returnTrip) {
    final theme = Theme.of(context);
    final outboundOrigin = getDisplayLocation(outbound['origin'] as String? ?? 'N/A');
    final outboundDest = getDisplayLocation(outbound['destination'] as String? ?? 'N/A');
    final returnOrigin = getDisplayLocation(returnTrip['origin'] as String? ?? 'N/A');
    final returnDest = getDisplayLocation(returnTrip['destination'] as String? ?? 'N/A');
    final outboundTime = outbound['originTime'] as String? ?? '';
    final returnTime = returnTrip['originTime'] as String? ?? '';
    final outboundDate = formatDate(outbound['date']);
    final returnDate = formatDate(returnTrip['date']);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      outboundOrigin,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Text(
                      outboundTime,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    const Icon(Icons.directions_bus, color: Colors.red, size: 24),
                    const SizedBox(height: 4),
                    Text(
                      outboundDate,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      outboundDest,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Text(
                      outbound['destinationTime'] as String? ?? '',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.arrow_forward, color: Colors.red, size: 16),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, color: Colors.red, size: 16),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      returnOrigin,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Text(
                      returnTime,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    const SizedBox(height: 24), 
                    const SizedBox(height: 4),

                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      returnDest,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Text(
                      returnTrip['destinationTime'] as String? ?? '',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<dynamic> getGroupedReservations(List<Map<String, dynamic>> reservations) {
    final Map<String, List<Map<String, dynamic>>> groups = {};
    for (final res in reservations) {
      final groupId = res['groupId'] as String? ?? (res['date'].toString() + '_' + res['origin'] + '_' + res['destination']); // Fallback for singles
      groups.putIfAbsent(groupId, () => []).add(res);
    }

    final List<dynamic> grouped = [];
    groups.forEach((groupId, groupRes) {
      if (groupRes.length == 2) {
        final outbound = groupRes.firstWhere((r) => r['origin'] == 'Santiago', orElse: () => groupRes[0]);
        final returnTrip = groupRes.firstWhere((r) => r['origin'] != 'Santiago', orElse: () => groupRes[1]);
        grouped.add([outbound, returnTrip]);
      } else {
        grouped.add(groupRes[0]);
      }
    });

    // Fechas más cercanas primero
    grouped.sort((a, b) {
      DateTime dateA;
      if (a is List) {
        final dates = a.map((r) {
          dynamic d = r['date'];
          if (d is DateTime) return d;
          return DateTime.parse(d as String);
        }).toList();
        dateA = dates.reduce((prev, current) => prev.isBefore(current) ? prev : current);
      } else {
        dynamic d = (a as Map)['date'];
        dateA = d is DateTime ? d : DateTime.parse(d as String);
      }
      DateTime dateB;
      if (b is List) {
        final dates = b.map((r) {
          dynamic d = r['date'];
          if (d is DateTime) return d;
          return DateTime.parse(d as String);
        }).toList();
        dateB = dates.reduce((prev, current) => prev.isBefore(current) ? prev : current);
      } else {
        dynamic d = (b as Map)['date'];
        dateB = d is DateTime ? d : DateTime.parse(d as String);
      }
      return dateA.compareTo(dateB);
    });

    return grouped;
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reservas',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                GestureDetector(
                  onTap: () { context.go('/transport/calendar');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red, width: 2),
                      borderRadius: BorderRadius.circular(12),
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
                    final group = grouped[index];
                    if (group is List<Map<String, dynamic>>) {
                      final outbound = group[0];
                      final returnTrip = group[1];
                      return buildRoundTripCard(outbound, returnTrip);
                    } else {
                      return buildHighlightedReservationCard(group as Map<String, dynamic>);
                    }
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

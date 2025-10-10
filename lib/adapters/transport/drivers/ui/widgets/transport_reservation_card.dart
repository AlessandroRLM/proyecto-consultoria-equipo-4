import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/adapters/core/driven/app_themes.dart';

class TransportReservationCard extends StatefulWidget {
  final Map<String, dynamic> reservation;

  const TransportReservationCard({super.key, required this.reservation});

  @override
  State<TransportReservationCard> createState() => _TransportReservationCardState();
}

class _TransportReservationCardState extends State<TransportReservationCard> {
  bool expanded = false;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final origin = widget.reservation['origin'] as String? ?? 'Origen no disponible';
    final destination = widget.reservation['destination'] as String? ?? 'Destino no disponible';
    final originTime = widget.reservation['originTime'] as String? ?? 'Hora no disponible';
    final date = widget.reservation['date'] as String?;
    final formattedDate = date != null ? formatDate(DateTime.parse(date)) : 'Fecha no disponible';
    final details = widget.reservation['details'] as String? ?? '';
    final isReturn = details.toLowerCase().contains('regreso');
    final isOutbound = details.toLowerCase().contains('ida');
    final tipo = isReturn ? 'REGRESO' : (isOutbound ? 'IDA' : 'Desconocido');
    final service = widget.reservation['service'] as String? ?? 'Servicio no disponible';

    return GestureDetector(
      onTap: () {
        setState(() {
          expanded = !expanded;
        });
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        color: null,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppThemes.black_500.withValues(alpha: 0.4)),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Icon(Icons.directions_bus, color: theme.colorScheme.primary, size: 28),
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
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Icon(Icons.arrow_forward, size: 18, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
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
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '$formattedDate - ${formatTime(originTime)}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            Text(
                              widget.reservation['status'] as String? ?? 'Estado desconocido',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                color: Colors.blue,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (expanded) ...[
                const Divider(height: 20, thickness: 1),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Tipo: ',
                            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: tipo,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Servicio: ',
                            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: service,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Origen: ',
                            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: origin,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Destino: ',
                            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: destination,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Dirección de origen: ',
                            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: '${widget.reservation['originAddress'] ?? 'No disponible'}',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Dirección de destino: ',
                            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: '${widget.reservation['destinationAddress'] ?? 'No disponible'}',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

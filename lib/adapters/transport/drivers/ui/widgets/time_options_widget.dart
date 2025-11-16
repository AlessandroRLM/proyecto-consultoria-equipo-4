import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//import 'package:mobile/adapters/transport/drivers/ui/screens/transport_time_selection_screen.dart';
import 'package:provider/provider.dart';
import 'package:mobile/adapters/transport/driven/providers/transport_reservations_provider.dart';
import 'package:mobile/adapters/core/driven/app_themes.dart';

String formatTime(String timeStr) {
  return timeStr;
}
class TimeOptionsWidget extends StatefulWidget {
  final List<Map<String, dynamic>> availableOptions;
  final Map<String, dynamic>? selectedOption;
  final Function(Map<String, dynamic>) onTimeSelected;
  final DateTime selectedDate;
  final bool isOutbound;

  const TimeOptionsWidget({
    super.key,
    required this.availableOptions,
    required this.selectedOption,
    required this.onTimeSelected,
    required this.selectedDate,
    required this.isOutbound,
  });

  @override
  State<TimeOptionsWidget> createState() => _TimeOptionsWidgetState();
}

class _TimeOptionsWidgetState extends State<TimeOptionsWidget> {
  final Map<String, bool> _loading = {};

  Future<void> _toggleReservation(String dateStr, String time, bool isCurrentlyReserved, String service) async {
    final provider = Provider.of<TransportReservationsProvider>(context, listen: false);
    if (_loading[time] == true) return;
    setState(() {
      _loading[time] = true;
    });
    bool success = false;
    if (!isCurrentlyReserved) {
      success = await provider.reserveLeg(date: dateStr, time: time, isOutbound: widget.isOutbound, service: service);
    } else {
      success = await provider.cancelLeg(date: dateStr, time: time, isOutbound: widget.isOutbound);
    }
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al actualizar la reserva')));
    }
    if (mounted) {
      setState(() {
        _loading[time] = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.availableOptions.isEmpty) {
      return Center(
        child: Text(
          'No hay opciones disponibles',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
        ),
      );
    }
    final provider = Provider.of<TransportReservationsProvider>(context);
    final dateStr = DateFormat('yyyy-MM-dd').format(widget.selectedDate);
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Row(
      children: widget.availableOptions.take(3).map((option) {
        final time = option['time'] as String;
        final service = option['service'] as String;
        final isSelected = widget.selectedOption != null && widget.selectedOption!['time'] == time;
        final isReserved = provider.isOptionReserved(dateStr, time, isOutbound: widget.isOutbound);
        final loading = _loading[time] ?? false;
        return Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              double buttonWidth = constraints.maxWidth;
              double fontSize = buttonWidth > 80 ? 14.0 : 12.0;
              double smallFontSize = buttonWidth > 80 ? 10.0 : 8.0;
              double iconSize = buttonWidth > 80 ? 18.0 : 14.0;
              double spacing = buttonWidth > 80 ? 6.0 : 3.0;
              return GestureDetector(
                onTap: () async {
                  if (_loading[time] == true) return;
                  await _toggleReservation(dateStr, time, isReserved, service);
                },
                child: Container(
                  height: 60,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? AppThemes.primary_300 : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppThemes.black_500,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.directions_bus,
                        color: isSelected ? AppThemes.primary_600 : onSurface,
                        size: iconSize,
                      ),
                      SizedBox(width: spacing),
                      Flexible(
                        child: buttonWidth > 80
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    formatTime(time),
                                    style: TextStyle(
                                      color: isSelected ? AppThemes.primary_600 : onSurface,
                                      fontSize: fontSize,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  Text(
                                    service,
                                    style: TextStyle(
                                      color: isSelected ? AppThemes.primary_600 : onSurface.withValues(alpha: 0.8),
                                      fontSize: smallFontSize,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              )
                            : Text(
                                '${formatTime(time)} - $service',
                                style: TextStyle(
                                  color: isSelected ? AppThemes.primary_600 : onSurface,
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                      ),
                      const SizedBox(width: 4),
                      SizedBox(
                        width: 28,
                        child: loading
                            ? const Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)))
                            : Checkbox(
                                value: isReserved,
                                onChanged: (val) async {
                                  await _toggleReservation(dateStr, time, isReserved, service);
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }
}

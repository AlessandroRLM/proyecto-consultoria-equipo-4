import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mobile/adapters/transport/driven/providers/transport_reservations_provider.dart';

class TransportCalendarScreen extends StatefulWidget {
  const TransportCalendarScreen({super.key});

  @override
  State<TransportCalendarScreen> createState() => _TransportCalendarScreenState();
}

class _TransportCalendarScreenState extends State<TransportCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  String? _selectedLocation;
  DateTime? _selectedWeekStart;

  final List<String> _weekdays = ['Lu', 'Ma', 'Mi', 'Ju', 'Vi', 'Sa', 'Do'];

  late TransportReservationsProvider _transportProvider;

  @override
  void initState() {
    super.initState();
    _transportProvider = Provider.of<TransportReservationsProvider>(context, listen: false);
    _fetchData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = GoRouterState.of(context);
      final args = state.extra as Map<String, dynamic>? ?? {};
      _selectedLocation = args['selectedLocation'];
    });
  }

  Future<void> _fetchData() async {
    await _transportProvider.fetchReservations();
  }

  List<DateTime> _getDaysInMonth(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    final firstDayOfWeek = firstDayOfMonth.weekday;

    List<DateTime> days = [];

    final previousMonth = DateTime(month.year, month.month - 1, 1);
    final lastDayOfPreviousMonth = DateTime(month.year, month.month, 0);
    for (int i = firstDayOfWeek - 1; i > 0; i--) {
      days.add(DateTime(previousMonth.year, previousMonth.month, lastDayOfPreviousMonth.day - i + 1));
    }

    for (int i = 1; i <= lastDayOfMonth.day; i++) {
      days.add(DateTime(month.year, month.month, i));
    }

    final remainingDays = 35 - days.length;
    for (int i = 1; i <= remainingDays; i++) {
      days.add(DateTime(month.year, month.month + 1, i));
    }
    if (days.length > 35) {
      days = days.sublist(0, 35);
    }

    return days;
  }

  void _previousMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
    });
  }

  void _onDaySelected(DateTime day) {
    final provider = _transportProvider;
    final dateStr = DateFormat('yyyy-MM-dd').format(day);

    if (day.isAfter(DateTime.now().add(const Duration(days: 365)))) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fecha demasiado lejana. Seleccione una fecha dentro del próximo año.')),
        );
      });
      return;
    }

    final isReserved = provider.reservations.any((r) => getDateString(r) == dateStr);
    if (isReserved) {
      final reserved = provider.reservations.firstWhere((r) => getDateString(r) == dateStr);
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _showDetailsDialog(reserved);
      });
      return;
    }

    if (provider.selectedLocation != null) {
      if (day.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se puede seleccionar una fecha pasada.')),
          );
        });
        return;
      }
      SchedulerBinding.instance.addPostFrameCallback((_) {
        provider.selectedDate = dateStr;
        context.push('/transport/time-selection', extra: {'isOutbound': true, 'fixedInitialDate': dateStr});
      });
      return;
    }

    if (day.weekday == DateTime.monday && provider.isWeekAllowed(day)) {
      setState(() {
        _selectedWeekStart = day;
      });
      return;
    }

    if (_selectedWeekStart != null && day.isAfter(_selectedWeekStart!.subtract(const Duration(days: 1))) && day.isBefore(_selectedWeekStart!.add(const Duration(days: 7)))) {
      if (_selectedLocation != null) {
        if (provider.hasAvailableOptions(dateStr)) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            context.push('/transport/time-selection', extra: {
              'location': _selectedLocation,
              'dateStr': dateStr,
              'weekStart': DateFormat('yyyy-MM-dd').format(_selectedWeekStart!),
            });
          });
        } else {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No hay opciones disponibles para esta fecha.')),
            );
          });
        }
      } else {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Seleccione una ubicación primero.')),
          );
        });
      }
      return;
    }

    SchedulerBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione un lunes para elegir la semana.')),
      );
    });
  }

  void _showDetailsDialog(Map<String, dynamic> reservation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalles de la reserva'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Servicio: ${reservation['service']}'),
            Text('Detalles: ${reservation['details']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  String? getDateString(Map<String, dynamic> r) {
    dynamic dateValue = r['date'];
    if (dateValue is DateTime) {
      return DateFormat('yyyy-MM-dd').format(dateValue);
    } else if (dateValue is String) {
      return dateValue;
    }
    return null;
  }



  @override
  Widget build(BuildContext context) {
    final days = _getDaysInMonth(_focusedDay);
    final monthName = DateFormat('MMMM', 'es_ES').format(_focusedDay);
    final capitalizedMonthName = monthName.isNotEmpty ? '${monthName[0].toUpperCase()}${monthName.substring(1)}' : monthName;

    return Consumer<TransportReservationsProvider>(
      builder: (context, transportProv, child) {
        final isNewFlow = transportProv.selectedLocation != null;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Reservar')
          ),
          body: Column(
            children: [
              const SizedBox(height: 12),
              Text(
                isNewFlow ? 'Seleccione la fecha del transporte' : 'Seleccione el dia del transporte',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.chevron_left, color: Theme.of(context).colorScheme.onSurface),
                      onPressed: _previousMonth,
                    ),
                    Text(
                      '$capitalizedMonthName ${_focusedDay.year}',
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurface),
                      onPressed: _nextMonth,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Column(
                          children: [
                            const SizedBox(height: 4),
                            Expanded(
                              child: GridView.builder(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 7,
                                  childAspectRatio: 0.833,
                                ),
                                itemCount: 35,
                                itemBuilder: (context, index) {
                                  final day = days[index];
                                  final isCurrentMonth = day.month == _focusedDay.month;
                                  final dateStr = DateFormat('yyyy-MM-dd').format(day);
                                  final isReserved = transportProv.reservations.any((r) => getDateString(r) == dateStr);
                                  final isInSelectedWeek = _selectedWeekStart != null && day.isAfter(_selectedWeekStart!.subtract(const Duration(days: 1))) && day.isBefore(_selectedWeekStart!.add(const Duration(days: 7)));
                                  final isPast = day.isBefore(DateTime.now().subtract(const Duration(days: 1)));
                                  final isSelectable = (isCurrentMonth && !isReserved && !isPast) && (isNewFlow || (day.weekday == DateTime.monday && transportProv.isWeekAllowed(day)) || isInSelectedWeek);

                                  Color borderColor = isCurrentMonth ? Colors.red : Colors.grey;
                                  Color textColor;
                                  Color? bgColor;

                                  if (isInSelectedWeek) {
                                    bgColor = Colors.red;
                                    textColor = Colors.white;
                                  } else if (isReserved) {
                                    bgColor = Colors.green.withValues(alpha: 0.3);
                                    textColor = Colors.green;
                                  } else if (isPast) {
                                    bgColor = Colors.grey.withValues(alpha: 0.3);
                                    textColor = Colors.grey;
                                  } else {
                                    bgColor = null;
                                    textColor = isCurrentMonth ? Colors.red : Colors.grey;
                                  }

                                  double borderWidth = 1.0;

                                  return GestureDetector(
                                    onTap: isSelectable ? () => _onDaySelected(day) : null,
                                    child: Container(
                                      margin: const EdgeInsets.all(1),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: borderColor, width: borderWidth),
                                        color: bgColor,
                                      ),
                                      child: Center(
                                        child: Stack(
                                          children: [
                                            Center(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    day.day.toString(),
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: textColor,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  Text(
                                                    _weekdays[day.weekday - 1],
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: textColor.withValues(alpha: 0.8),
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (isReserved)
                                              const Positioned(
                                                bottom: 2,
                                                right: 2,
                                                child: Icon(
                                                  Icons.check,
                                                  size: 12,
                                                  color: Colors.green,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mis Reservas',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Expanded(
                              child: transportProv.reservations.isEmpty
                                ? const Center(child: Text('No hay reservas de transporte'))
                                : ListView.builder(
                                    itemCount: transportProv.reservations.length,
                                    itemBuilder: (context, index) {
                                      final res = transportProv.reservations[index];
                                      final dateValue = res['date'];
                                      String? dateStr;
                                      if (dateValue is DateTime) {
                                        dateStr = DateFormat('yyyy-MM-dd').format(dateValue);
                                      } else if (dateValue is String) {
                                        dateStr = dateValue;
                                      }
                                      String subtitle = res['details'] ?? '';
                                      if (dateStr != null) {
                                        final date = DateTime.parse(dateStr);
                                        final weekday = DateFormat('EEEE', 'es_ES').format(date);
                                        final formattedDate = DateFormat('dd/MM/yyyy').format(date);
                                        subtitle = '$weekday $formattedDate - $subtitle';
                                      }
                                      return ListTile(
                                        dense: true,
                                        leading: const Icon(Icons.directions_bus, size: 20),
                                        title: Text(res['service'] ?? 'Reserva', style: const TextStyle(fontSize: 12)),
                                        subtitle: Text(subtitle, style: const TextStyle(fontSize: 10)),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.delete, size: 16),
                                          onPressed: () => transportProv.removeReservation(index),
                                        ),
                                        onTap: () => _showDetailsDialog(res),
                                      );
                                    },
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mobile/adapters/transport/driven/providers/transport_reservations_provider.dart';
import 'package:mobile/adapters/core/driven/app_themes.dart';
import 'package:flutter/scheduler.dart';

class TransportTimeSelectionScreen extends StatefulWidget {
  final String? location;
  final String? dateStr;
  final String? fixedInitialDate;
  final bool isOutbound;

  const TransportTimeSelectionScreen({
    super.key,
    this.location,
    this.dateStr,
    this.fixedInitialDate,
    this.isOutbound = false,
  });

  @override
  State<TransportTimeSelectionScreen> createState() => _TransportTimeSelectionScreenState();
}

class _TransportTimeSelectionScreenState extends State<TransportTimeSelectionScreen> {
  Map<String, dynamic>? _selectedOption;
  String? _selectedLocation;
  DateTime? _focusedWeekStart;
  DateTime? _selectedDate;
  bool _isOutbound = true;
  int _selectedTabIndex = 0;
  List<Map<String, dynamic>> _availableOptions = [];

  final List<String> _weekdays = ['Lu', 'Ma', 'Mi', 'Ju', 'Vi', 'Sa', 'Do'];

  late TransportReservationsProvider _transportProvider;

  @override
  void initState() {
    super.initState();
    _isOutbound = widget.isOutbound ?? true;
    _selectedTabIndex = _isOutbound ? 0 : 1;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _transportProvider = Provider.of<TransportReservationsProvider>(context, listen: false);
    _selectedLocation = (widget.location != null && widget.location!.isNotEmpty) ? widget.location : _transportProvider.selectedLocation;
    DateTime now = DateTime.now();
    _focusedWeekStart = _getMondayOfWeek(now);
    if (widget.fixedInitialDate != null && widget.fixedInitialDate!.isNotEmpty) {
      final fixedDate = DateTime.parse(widget.fixedInitialDate!);
      _selectedDate = fixedDate;
      _focusedWeekStart = _getMondayOfWeek(fixedDate);
    } else if (widget.dateStr != null && widget.dateStr!.isNotEmpty) {
      final selected = DateTime.parse(widget.dateStr!);
      _selectedDate = selected;
      _focusedWeekStart = _getMondayOfWeek(selected);
    }
    if (_selectedDate == null && _transportProvider.selectedDate != null) {
      _selectedDate = DateTime.parse(_transportProvider.selectedDate!);
      _focusedWeekStart = _getMondayOfWeek(_selectedDate!);
    }
    if (!_isOutbound && _transportProvider.selectedDate != null) {
      final outboundDate = DateTime.parse(_transportProvider.selectedDate!);
      _focusedWeekStart = _getMondayOfWeek(outboundDate);
      if (widget.fixedInitialDate != null) {
        _selectedDate = DateTime.parse(widget.fixedInitialDate!);
      }
    }
    _fetchData();
  }

  DateTime _getMondayOfWeek(DateTime date) {
    int daysToSubtract = date.weekday - DateTime.monday;
    return date.subtract(Duration(days: daysToSubtract));
  }

  Future<void> _fetchData() async {
    await _transportProvider.fetchReservations();
    _loadAvailableOptions();
  }

  void _loadAvailableOptions() {
    if (_transportProvider != null && _selectedDate != null) {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      _availableOptions = _transportProvider.getAvailableOptionsForDate(dateStr);
      if (_availableOptions.isEmpty) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No hay opciones disponibles para esta fecha.')),
          );
        });
      }
      setState(() {});
    } else if (_selectedDate == null) {
      // Default fecha hoy si no hay una seleccionada.
      final now = DateTime.now();
      final dateStr = DateFormat('yyyy-MM-dd').format(now);
      setState(() {
        _selectedDate = now;
        _focusedWeekStart = _getMondayOfWeek(now);
        _availableOptions = _transportProvider.getAvailableOptionsForDate(dateStr);
      });
    }
  }

  void _onTimeSelected(Map<String, dynamic> option) {
    setState(() {
      _selectedOption = option;
    });
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedTabIndex = index;
      _isOutbound = index == 0;
      _selectedOption = null; 
      if (!_isOutbound && (_transportProvider.selectedDate == null || _transportProvider.selectedOutboundTime == null)) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Primero seleccione fecha y hora de ida.')),
          );
        });
        setState(() {
          _selectedTabIndex = 0;
          _isOutbound = true;
        });
        return;
      }

      if (!_isOutbound && _transportProvider.selectedDate != null) {
        final outboundDate = DateTime.parse(_transportProvider.selectedDate!);
        _focusedWeekStart = _getMondayOfWeek(outboundDate);
        _selectedDate ??= outboundDate;
      }

      if (index == 1 && widget.fixedInitialDate != null && widget.fixedInitialDate!.isNotEmpty) {
        _selectedDate = DateTime.parse(widget.fixedInitialDate!);
      }
      _loadAvailableOptions();
    });
  }

  List<DateTime> _getDaysInWeek() {
    if (_focusedWeekStart == null) return [];
    List<DateTime> days = [];
    for (int i = 0; i < 7; i++) { 
      final day = _focusedWeekStart!.add(Duration(days: i));
      days.add(day);
    }
    return days;
  }

  void _previousWeek() {
    if (_focusedWeekStart == null) return;
    setState(() {
      _focusedWeekStart = _focusedWeekStart!.subtract(const Duration(days: 7));
    });
  }

  void _nextWeek() {
    if (_focusedWeekStart == null) return;
    setState(() {
      _focusedWeekStart = _focusedWeekStart!.add(const Duration(days: 7));
    });
  }

  void _onDaySelected(DateTime day) {
    if (_selectedOption != null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se puede cambiar la fecha ya seleccionada anteriormente')),
        );
      });
      return;
    }
    if (!_isOutbound) {
      if (_transportProvider != null && _transportProvider.selectedDate != null) {
        final outboundDate = DateTime.parse(_transportProvider.selectedDate!);
        if (day.isBefore(outboundDate)) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('La fecha de vuelta no puede ser anterior a la fecha de ida.')),
            );
          });
          return;
        }
      }
    }
    setState(() {
      _selectedDate = day;
      _focusedWeekStart = _getMondayOfWeek(day);
    });
    _loadAvailableOptions();
  }

  String _formatTime(String timeStr) {
    if (timeStr.contains('AM') || timeStr.contains('PM')) {
      return timeStr;
    }
    final parts = timeStr.split(':');
    if (parts.length != 2) return timeStr;
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);
    String period = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12;
    if (hour == 0) hour = 12;
    return '${hour.toString().padLeft(2, '0')}:${parts[1]} $period';
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

  void _onReservar() {
    if (_selectedDate == null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, seleccione una fecha primero.')),
        );
      });
      return;
    }
    if (_selectedOption == null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, seleccione una hora primero.')),
        );
      });
      return;
    }

    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);

    if (_isOutbound) {
      _transportProvider.selectedDate = dateStr;
      _transportProvider.selectedOutboundTime = _selectedOption!['time'];
      _transportProvider.selectedService = _selectedOption!['service'];
      _onTabSelected(1);
    } else {
      if (_transportProvider.selectedOutboundTime == _selectedOption!['time']) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('La hora de vuelta no puede ser la misma que la de ida.')),
          );
        });
        return;
      }
      final returnDateStr = dateStr;
      _transportProvider.selectedReturnDate = returnDateStr;
      _transportProvider.selectedReturnTime = _selectedOption!['time'];
      _transportProvider.selectedService = _selectedOption!['service'];
      _transportProvider.addRoundTripReservation();
      SchedulerBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reservas de ida y vuelta confirmadas.')),
        );
      });
      context.go('/transport');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_focusedWeekStart == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final days = _getDaysInWeek();
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final primary = theme.colorScheme.primary;
    final onPrimary = theme.colorScheme.onPrimary;
    final surfaceVariant = theme.colorScheme.surfaceVariant;

    final timeLabel = _isOutbound ? 'ida' : 'vuelta';
    final displayDate = _selectedDate ?? _focusedWeekStart!;
    final monthYear = DateFormat('MMMM yyyy', 'es_ES').format(displayDate);
    final capitalizedMonth = monthYear[0].toUpperCase() + monthYear.substring(1);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('Seleccionar $timeLabel'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Tabs
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _onTabSelected(0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: _selectedTabIndex == 0 ? primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: primary,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Ida',
                                    style: TextStyle(
                                      color: _selectedTabIndex == 0 ? onPrimary : onSurface,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_upward,
                                    color: _selectedTabIndex == 0 ? onPrimary : onSurface,
                                    size: 14,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _onTabSelected(1),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: _selectedTabIndex == 1 ? primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: primary,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Vuelta',
                                    style: TextStyle(
                                      color: _selectedTabIndex == 1 ? onPrimary : onSurface,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_downward,
                                    color: _selectedTabIndex == 1 ? onPrimary : onSurface,
                                    size: 14,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Seleccione la fecha y hora del transporte de $timeLabel',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      height: 48,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.chevron_left, color: primary),
                            onPressed: _previousWeek,
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                capitalizedMonth,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.chevron_right, color: primary),
                            onPressed: _nextWeek,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Calendario horizontal
                  SizedBox(
                    height: 60,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: days.asMap().entries.map((entry) {
                          final int index = entry.key;
                          final day = entry.value;
                          final now = DateTime.now();
                          final dateStr = DateFormat('yyyy-MM-dd').format(day);
                          final isPast = day.isBefore(now.subtract(const Duration(days: 1)));
                          final isReserved = _transportProvider.reservations.any((r) => getDateString(r) == dateStr);
                          final hasOptions = _transportProvider.hasAvailableOptions(dateStr);
                          final isSelected = _selectedDate != null && _selectedDate!.isAtSameMomentAs(day);
                          final isSelectable = !isPast && !isReserved && hasOptions;

                          return Material(
                            color: Colors.transparent,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: (isSelectable && !(!_isOutbound && _selectedDate != null)) ? () {
                                if (!_isOutbound && _selectedDate != null) {
                                  SchedulerBinding.instance.addPostFrameCallback((_) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('No se puede cambiar la fecha en la vuelta después de seleccionarla.')),
                                    );
                                  });
                                  return;
                                }
                                _onDaySelected(day);
                              } : null,
                              child: Container(
                                width: 50,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? primary
                                      : isReserved
                                          ? Colors.green.withOpacity(0.3)
                                          : isPast || !hasOptions
                                              ? surfaceVariant.withOpacity(0.3)
                                              : null,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: primary,
                                    width: 1.0,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Align(
                                      alignment: Alignment.center,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Text(
                                            day.day.toString(),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: isSelected
                                                  ? onPrimary
                                                  : isReserved
                                                      ? Colors.green
                                                      : isPast || !hasOptions
                                                          ? Colors.grey
                                                          : primary,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _weekdays[index],
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: (isSelected
                                                      ? onPrimary
                                                      : isReserved
                                                          ? Colors.green
                                                          : isPast || !hasOptions
                                                              ? Colors.grey
                                                              : primary)
                                                  .withOpacity(0.8),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isReserved)
                                      Positioned(
                                        right: 2,
                                        top: 2,
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
                        }).toList(),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        if (_availableOptions.isEmpty)
                          const Center(
                            child: Text(
                              'No hay opciones disponibles',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        else
                          Row(
                            children: _availableOptions.take(3).map((option) {
                              final time = option['time'] as String;
                              final service = option['service'] as String;
                              final isSelected = _selectedOption != null && _selectedOption!['time'] == time;
                              final onSurface = Theme.of(context).colorScheme.onSurface;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () => _onTimeSelected(option),
                                  child: Container(
                                    height: 60,
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    decoration: BoxDecoration(
                                      color: isSelected ? Colors.red : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.red,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.directions_bus,
                                          color: isSelected ? Colors.white : onSurface,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _formatTime(time),
                                              style: TextStyle(
                                                color: isSelected ? Colors.white : onSurface,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              service,
                                              style: TextStyle(
                                                color: isSelected ? Colors.white : onSurface.withOpacity(0.8),
                                                fontSize: 10,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Divider(color: Colors.transparent, height: 0),
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  spreadRadius: 0,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transporte de ${_isOutbound ? 'Ida' : 'Vuelta'}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (_selectedLocation?.isNotEmpty ?? false)
                        Text(
                          '$_selectedLocation',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: onSurface.withOpacity(0.7),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: _onReservar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Reservar',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mobile/adapters/transport/driven/providers/transport_reservations_provider.dart';
import 'package:flutter/scheduler.dart';
import 'package:mobile/adapters/core/driven/app_themes.dart';

String formatTime(String timeStr) {
  return timeStr;
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

DateTime getMondayOfWeek(DateTime date) {
  int daysToSubtract = date.weekday - DateTime.monday;
  return date.subtract(Duration(days: daysToSubtract));
}

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
  DateTime? _allowedStart;
  DateTime? _allowedEnd;
  bool _isOutbound = true;
  int _selectedTabIndex = 0;
  List<Map<String, dynamic>> _availableOptions = [];

  final List<String> _weekdays = ['Lu', 'Ma', 'Mi', 'Ju', 'Vi', 'Sa', 'Do'];

  late TransportReservationsProvider _transportProvider;

  @override
  void initState() {
    super.initState();
    _isOutbound = widget.isOutbound;
    _selectedTabIndex = _isOutbound ? 0 : 1;
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedTabIndex = index;
      _isOutbound = index == 0;
      if (index == 0) {
        _allowedStart = _transportProvider.getMinReservableDate();
        _allowedEnd = _allowedStart!.add(Duration(days: 365));
      } else if (!_isOutbound) {
        _allowedStart = _transportProvider.getMinReservableDate();
        _allowedEnd = _allowedStart!.add(Duration(days: 365));
        if (_transportProvider.selectedDate != null) {
          final outboundDate = DateTime.parse(_transportProvider.selectedDate!);
          _focusedWeekStart = getMondayOfWeek(outboundDate);
        }
        _selectedDate = null;
        _selectedOption = null;
        _transportProvider.selectedReturnTime = null;
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
    if (_selectedDate != null && _selectedDate!.isAtSameMomentAs(day)) {
      setState(() {
        _selectedDate = null;
        if (_isOutbound) {
          _transportProvider.selectedDate = null;
          _transportProvider.selectedOutboundTime = null;
        } else {
          _transportProvider.selectedReturnDate = null;
          _transportProvider.selectedReturnTime = null;
        }
        _selectedOption = null;
        _transportProvider.selectedService = null;
        _availableOptions = [];
      });
      return;
    }

    if (day.isBefore(_allowedStart!) || day.isAfter(_allowedEnd!)) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fecha fuera del rango permitido')),
        );
      });
      return;
    }
    setState(() {
      _selectedDate = day;
      _focusedWeekStart = getMondayOfWeek(day);
      if (_isOutbound) {
        _transportProvider.selectedDate = DateFormat('yyyy-MM-dd').format(day);
        _transportProvider.selectedOutboundTime = null;
      } else {
        _transportProvider.selectedReturnDate = DateFormat('yyyy-MM-dd').format(day);
        _transportProvider.selectedReturnTime = null;
      }
      _selectedOption = null;
      _transportProvider.selectedService = null;
    });
    _loadAvailableOptions();
  }

  void _loadAvailableOptions({bool? isOutbound}) {
    final outbound = isOutbound ?? _isOutbound;
    if (_selectedDate != null) {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      _availableOptions = _transportProvider.getAvailableOptionsForDate(dateStr, isOutbound: outbound);
      if (_availableOptions.isEmpty) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No hay opciones disponibles para esta fecha.')),
          );
        });
      }
      setState(() {});
    } else {
      DateTime defaultDate = _allowedStart ?? DateTime.now();
      final latestDate = _getLatestReservationDate();
      if (latestDate != null && outbound) {
        defaultDate = latestDate.add(Duration(days: 1));
        if (defaultDate.isBefore(_allowedStart!)) {
          defaultDate = _allowedStart!;
        }
      } else if (_transportProvider.selectedDate != null) {
        defaultDate = DateTime.parse(_transportProvider.selectedDate!);
        if (defaultDate.isBefore(_allowedStart!)) {
          defaultDate = _allowedStart!;
        }
      }
      final dateStr = DateFormat('yyyy-MM-dd').format(defaultDate);
      setState(() {
        _focusedWeekStart = getMondayOfWeek(defaultDate);
        _availableOptions = _transportProvider.getAvailableOptionsForDate(dateStr, isOutbound: outbound);
      });
    }
  }

  void _onTimeSelected(Map<String, dynamic> option) {
    setState(() {
      if (_selectedOption != null && _selectedOption!['time'] == option['time']) {
        _selectedOption = null;
        if (_isOutbound) {
          _transportProvider.selectedOutboundTime = null;
        } else {
          _transportProvider.selectedReturnTime = null;
        }
        _transportProvider.selectedService = null;
      } else {
        _selectedOption = option;
        if (_isOutbound) {
          _transportProvider.selectedOutboundTime = option['time'];
        } else {
          _transportProvider.selectedReturnTime = option['time'];
        }
        _transportProvider.selectedService = option['service'];
      }
    });
  }
  
  void _onReservar() {
    if (_selectedLocation == null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, seleccione una ubicación primero.')),
        );
      });
      return;
    }
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
      _transportProvider.addOutboundReservation();
      SchedulerBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reserva confirmada con exito.')),
        );
      });
      _onTabSelected(1);
    } else {
      if (_transportProvider.selectedOutboundTime != null) {
        if (dateStr != _transportProvider.selectedDate && _transportProvider.selectedOutboundTime == _selectedOption!['time']) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('La hora de vuelta no puede ser la misma que la de ida.')),
            );
          });
          return;
        }
        _transportProvider.selectedReturnDate = dateStr;
        _transportProvider.selectedReturnTime = _selectedOption!['time'];
        _transportProvider.selectedService = _selectedOption!['service'];
        _transportProvider.addRoundTripReservation();
        SchedulerBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reserva confirmada con exito.')),
          );
        });
        context.go('/transport');
      } else {
        _transportProvider.selectedReturnDate = dateStr;
        _transportProvider.selectedReturnTime = _selectedOption!['time'];
        _transportProvider.selectedService = _selectedOption!['service'];
        _transportProvider.addReturnReservation();
        SchedulerBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reserva confirmada con exito.')),
          );
        });
        context.go('/transport');
      }
    }
  }

  DateTime? _getLatestReservationDate() {
    if (_transportProvider.reservations.isEmpty) return null;
    DateTime? latest = null;
    for (var res in _transportProvider.reservations) {
      DateTime? outboundDate;
      if (res['outbound'] != null && res['outbound']['date'] != null) {
        outboundDate = DateTime.parse(res['outbound']['date']);
      }
      DateTime? returnDate;
      if (res['return'] != null && res['return']['date'] != null) {
        returnDate = DateTime.parse(res['return']['date']);
      }
      DateTime? resLatest = outboundDate;
      if (returnDate != null && (resLatest == null || returnDate.isAfter(resLatest))) {
        resLatest = returnDate;
      }
      if (resLatest != null && (latest == null || resLatest.isAfter(latest))) {
        latest = resLatest;
      }
    }
    return latest;
  }

  Future<void> _fetchData() async {
    await _transportProvider.fetchReservations();
    _loadAvailableOptions();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _transportProvider = Provider.of<TransportReservationsProvider>(context, listen: false);
    _selectedLocation = _transportProvider.selectedLocation?['name'];
    _allowedStart = _transportProvider.getMinReservableDate();
    _allowedEnd = _allowedStart!.add(Duration(days: 365));
    _focusedWeekStart = _allowedStart;
    if (widget.fixedInitialDate != null && widget.fixedInitialDate!.isNotEmpty) {
      final fixedDate = DateTime.parse(widget.fixedInitialDate!);
      _selectedDate = fixedDate;
      _focusedWeekStart = getMondayOfWeek(fixedDate);
    } else if (widget.dateStr != null && widget.dateStr!.isNotEmpty) {
      final selected = DateTime.parse(widget.dateStr!);
      _selectedDate = selected;
      _focusedWeekStart = getMondayOfWeek(selected);
    }
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    if (_focusedWeekStart == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final days = _getDaysInWeek();
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final primary = theme.colorScheme.primary;
    final onPrimary = theme.colorScheme.onPrimary;
    final surfaceContainerHighest = theme.brightness == Brightness.light ? AppThemes.black_300 : AppThemes.black_900;

    final timeLabel = _isOutbound ? 'ida' : 'vuelta';

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
                  TabsWidget(
                    selectedTabIndex: _selectedTabIndex,
                    onTabSelected: _onTabSelected,
                    primaryColor: primary,
                    onPrimaryColor: onPrimary,
                    onSurfaceColor: onSurface,
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
                  WeekCalendarWidget(
                    days: days,
                    selectedDate: _selectedDate,
                    onDaySelected: _onDaySelected,
                    focusedWeekStart: _focusedWeekStart!,
                    previousWeek: _previousWeek,
                    nextWeek: _nextWeek,
                    primaryColor: primary,
                    onPrimaryColor: onPrimary,
                    onSurfaceContainerHighestColor: surfaceContainerHighest,
                    onSurfaceColor: onSurface,
                    transportProvider: _transportProvider,
                    weekdays: _weekdays,
                    isOutbound: _isOutbound,
                    allowedStart: _allowedStart,
                    allowedEnd: _allowedEnd,
                  ),
                  const SizedBox(height: 16),
                  if (_selectedDate != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TimeOptionsWidget(
                        availableOptions: _availableOptions,
                        selectedOption: _selectedOption,
                        onTimeSelected: _onTimeSelected,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const Divider(color: Colors.transparent, height: 0),
          ReservationButtonWidget(
            isOutbound: _isOutbound,
            selectedLocation: _selectedLocation,
            selectedOption: _selectedOption,
            onReservar: _onReservar,
          ),
        ],
      ),
    );
  }
}

class TabsWidget extends StatelessWidget {
  final int selectedTabIndex;
  final Function(int) onTabSelected;
  final Color primaryColor;
  final Color onPrimaryColor;
  final Color onSurfaceColor;

  const TabsWidget({
    super.key,
    required this.selectedTabIndex,
    required this.onTabSelected,
    required this.primaryColor,
    required this.onPrimaryColor,
    required this.onSurfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onTabSelected(0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: selectedTabIndex == 0 ? AppThemes.primary_300 : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppThemes.black_500,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_upward,
                      color: selectedTabIndex == 0 ? AppThemes.primary_600 : onSurfaceColor,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Ida',
                      style: TextStyle(
                        color: selectedTabIndex == 0 ? AppThemes.primary_600 : onSurfaceColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: () => onTabSelected(1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: selectedTabIndex == 1 ? AppThemes.primary_300 : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppThemes.black_500,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_downward,
                      color: selectedTabIndex == 1 ? AppThemes.primary_600 : onSurfaceColor,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Vuelta',
                      style: TextStyle(
                        color: selectedTabIndex == 1 ? AppThemes.primary_600 : onSurfaceColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WeekCalendarWidget extends StatelessWidget {
  final List<DateTime> days;
  final DateTime? selectedDate;
  final Function(DateTime) onDaySelected;
  final DateTime focusedWeekStart;
  final VoidCallback previousWeek;
  final VoidCallback nextWeek;
  final Color primaryColor;
  final Color onPrimaryColor;
  final Color onSurfaceContainerHighestColor;
  final Color onSurfaceColor;
  final TransportReservationsProvider transportProvider;
  final List<String> weekdays;
  final bool isOutbound;
  final DateTime? allowedStart;
  final DateTime? allowedEnd;

  const WeekCalendarWidget({
    super.key,
    required this.days,
    required this.selectedDate,
    required this.onDaySelected,
    required this.focusedWeekStart,
    required this.previousWeek,
    required this.nextWeek,
    required this.primaryColor,
    required this.onPrimaryColor,
    required this.onSurfaceContainerHighestColor,
    required this.onSurfaceColor,
    required this.transportProvider,
    required this.weekdays,
    required this.isOutbound,
    required this.allowedStart,
    required this.allowedEnd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final capitalizedMonth = DateFormat('MMMM yyyy', 'es_ES').format(focusedWeekStart);
    final capitalizedMonthFormatted = capitalizedMonth[0].toUpperCase() + capitalizedMonth.substring(1);

    return LayoutBuilder(
      builder: (context, constraints) {
        double availableWidth = constraints.maxWidth;
        double rowPaddingHorizontal = 32.0; 
        double effectiveDayWidth = (availableWidth - rowPaddingHorizontal) / 7;
        double dayHeight = effectiveDayWidth * (60.0 / 50.0);
        double fontSize = effectiveDayWidth > 40 ? 16.0 : 14.0;
        double smallFontSize = fontSize * 0.625;
        double iconSize = 12.0;
        double dayMargin = effectiveDayWidth > 50 ? 2.0 : 0.0;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 48,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.chevron_left, color: primaryColor.withValues(alpha: 0.3)),
                      onPressed: previousWeek,
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          capitalizedMonthFormatted,
                          style: TextStyle(
                            fontSize: 18,
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.chevron_right, color: primaryColor.withValues(alpha: 0.3)),
                      onPressed: nextWeek,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: dayHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: days.asMap().entries.map((entry) {
                    final int index = entry.key;
                    final day = entry.value;
                    final now = DateTime.now();
                    final dateStr = DateFormat('yyyy-MM-dd').format(day);
                    final isPast = day.isBefore(now.subtract(const Duration(days: 1)));
                    final direction = isOutbound ? 'IDA' : 'REGRESO';
                    final isReserved = isOutbound ? transportProvider.hasOutboundOnDate(dateStr) : transportProvider.hasReturnOnDate(dateStr);
                    final hasOptions = transportProvider.hasAvailableOptions(dateStr);
                    final isSelected = selectedDate != null && selectedDate!.isAtSameMomentAs(day);
                    final isSelectable = !isPast && !isReserved && hasOptions && !day.isBefore(allowedStart!) && !day.isAfter(allowedEnd!);

                    final isOutboundDate = !isOutbound && transportProvider.selectedDate != null && DateTime.parse(transportProvider.selectedDate!).isAtSameMomentAs(day);
                    final isHighlighted = isSelected;
                    return Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                            onTap: isSelectable ? () => onDaySelected(day) : null,
                          child: Container(
                            width: double.infinity,
                            height: dayHeight,
                            margin: EdgeInsets.symmetric(horizontal: dayMargin),
                            decoration: BoxDecoration(
                              color: isHighlighted
                                  ? primaryColor
                                  : !isSelectable
                                      ? onSurfaceContainerHighestColor.withValues(alpha: 0.3)
                                      : null,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isReserved ? Colors.green : (!isSelectable ? onSurfaceColor.withValues(alpha: 0.3) : (day.weekday == DateTime.thursday ? Colors.yellow.shade700 : primaryColor)),
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
                                          color: isHighlighted
                                              ? onPrimaryColor
                                              : isReserved
                                                  ? theme.colorScheme.onSurface
                                                  : !isSelectable
                                                      ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                                                      : primaryColor,
                                          fontWeight: FontWeight.w500,
                                          fontSize: fontSize,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        weekdays[index],
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: (isHighlighted
                                                  ? onPrimaryColor
                                                  : isReserved
                                                      ? theme.colorScheme.onSurface
                                                  : !isSelectable
                                                      ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                                                      : primaryColor)
                                              .withValues(alpha: 0.8),
                                          fontSize: smallFontSize,
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
                                      size: iconSize,
                                      color: Colors.green,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class TimeOptionsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> availableOptions;
  final Map<String, dynamic>? selectedOption;
  final Function(Map<String, dynamic>) onTimeSelected;

  const TimeOptionsWidget({
    super.key,
    required this.availableOptions,
    required this.selectedOption,
    required this.onTimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (availableOptions.isEmpty) {
      return Center(
        child: Text(
          'No hay opciones disponibles',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
        ),
      );
    }
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Row(
      children: availableOptions.take(3).map((option) {
        final time = option['time'] as String;
        final service = option['service'] as String;
        final isSelected = selectedOption != null && selectedOption!['time'] == time;
        return Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              double buttonWidth = constraints.maxWidth;
              double fontSize = buttonWidth > 80 ? 14.0 : 12.0;
              double smallFontSize = buttonWidth > 80 ? 10.0 : 8.0;
              double iconSize = buttonWidth > 80 ? 20.0 : 16.0;
              double spacing = buttonWidth > 80 ? 8.0 : 4.0;
              return GestureDetector(
                onTap: () => onTimeSelected(option),
                child: Container(
                  height: 60,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
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

class ReservationButtonWidget extends StatelessWidget {
  final bool isOutbound;
  final String? selectedLocation;
  final Map<String, dynamic>? selectedOption;
  final VoidCallback onReservar;

  const ReservationButtonWidget({
    super.key,
    required this.isOutbound,
    required this.selectedLocation,
    required this.selectedOption,
    required this.onReservar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
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
                  'Transporte de ${isOutbound ? 'Ida' : 'Vuelta'}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                if (selectedLocation?.isNotEmpty ?? false)
                  Text(
                    '$selectedLocation',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: onSurface.withValues(alpha: 0.7),
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
              onPressed: selectedOption != null ? onReservar : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedOption != null ? AppThemes.primary_600 : theme.colorScheme.onSurface.withValues(alpha: 0.5),
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
    );
  }
}

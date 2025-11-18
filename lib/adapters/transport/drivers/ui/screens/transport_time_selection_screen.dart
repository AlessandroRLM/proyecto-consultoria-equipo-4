import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mobile/adapters/transport/driven/providers/transport_reservations_provider.dart';
import 'package:flutter/scheduler.dart';
import 'package:mobile/adapters/core/driven/app_themes.dart';
import 'package:mobile/adapters/transport/drivers/ui/widgets/widgets.dart';
import 'package:mobile/ports/transport/driven/for_querying_transport.dart';

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

    final dateStrForRangeCheck = DateFormat('yyyy-MM-dd').format(day);
    final isReservedForThisTab = _isOutbound
        ? _transportProvider.hasOutboundOnDate(dateStrForRangeCheck)
        : _transportProvider.hasReturnOnDate(dateStrForRangeCheck);
    if (!isReservedForThisTab) {
      if (day.isBefore(_allowedStart!) || day.isAfter(_allowedEnd!)) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fecha fuera del rango permitido')),
          );
        });
        return;
      }
    }

    final dateStr = DateFormat('yyyy-MM-dd').format(day);
    
    setState(() {
      _selectedDate = day;
      _focusedWeekStart = getMondayOfWeek(day);
      if (_isOutbound) {
        _transportProvider.selectedDate = dateStr;
        _transportProvider.selectedOutboundTime = null;
      } else {
        _transportProvider.selectedReturnDate = dateStr;
        _transportProvider.selectedReturnTime = null;
      }
      _selectedOption = null;
      _transportProvider.selectedService = null;
    });

    _loadAvailableOptions();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Map<String, dynamic>? reservedOption;
      for (var opt in _availableOptions) {
        try {
          if (_transportProvider.isOptionReserved(dateStr, opt['time'], isOutbound: _isOutbound)) {
            reservedOption = Map<String, dynamic>.from(opt);
            break;
          }
        } catch (_) {
        }
      }

      if (reservedOption != null) {
        final ro = reservedOption;
        if (_isOutbound) {
          _transportProvider.selectedOutboundTime = ro['time'];
        } else {
          _transportProvider.selectedReturnTime = ro['time'];
        }
        _transportProvider.selectedService = ro['service'];
      }
    });
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
  
  

  DateTime? _getLatestReservationDate() {
    if (_transportProvider.reservations.isEmpty) return null;
    DateTime? latest;
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
    _transportProvider.loadServices(const TransportServiceQuery());
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
        automaticallyImplyLeading: false,
        title: const SizedBox.shrink(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 16.0, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Seleccionar $timeLabel',
                      style: theme.textTheme.displayMedium,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  'Seleccione la fecha y hora del transporte de $timeLabel',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(height: 8),
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
                          selectedDate: _selectedDate!,
                          isOutbound: _isOutbound,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const Divider(color: Colors.transparent, height: 0),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: 220, // Ajusta este ancho para modificar el tamaño del botón.
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/transport'),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    label: const Text('Volver a mis reservas'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

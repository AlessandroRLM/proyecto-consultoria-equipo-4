import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../driven/providers/lodging_provider.dart';
import 'package:mobile/adapters/core/driven/app_themes.dart';

typedef DateRangeSelectedCallback = void Function(DateTime start, DateTime end);

class LodgingWeekCalendar extends StatefulWidget {
  final DateTime focusedWeekStart;
  final DateTime allowedStart;
  final DateTime allowedEnd;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final List<LodgingReservation> reservations;
  final DateRangeSelectedCallback onDateRangeSelected;

  const LodgingWeekCalendar({
    super.key,
    required this.focusedWeekStart,
    required this.allowedStart,
    required this.allowedEnd,
    this.initialStartDate,
    this.initialEndDate,
    required this.reservations,
    required this.onDateRangeSelected,
  });

  @override
  _LodgingWeekCalendarState createState() => _LodgingWeekCalendarState();
}

class _LodgingWeekCalendarState extends State<LodgingWeekCalendar> {
  late DateTime _focusedWeekStart;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  @override
  void initState() {
    super.initState();
    _focusedWeekStart = widget.allowedStart;
    _selectedStartDate = widget.initialStartDate;
    _selectedEndDate = widget.initialEndDate;
  }

    List<DateTime> _getDaysInWeek() {
      List<DateTime> days = [];
      for (int i = 0; i < 7; i++) {
        final day = _focusedWeekStart.add(Duration(days: i));
        days.add(day);
      }
      return days;
    }

  void _previousWeek() {
    final newFocused = _focusedWeekStart.subtract(const Duration(days: 7));
    if (!newFocused.isBefore(widget.allowedStart)) {
      setState(() {
        _focusedWeekStart = newFocused;
      });
    }
  }

  void _nextWeek() {
    final newFocused = _focusedWeekStart.add(const Duration(days: 7));
    if (!newFocused.isAfter(widget.allowedEnd.subtract(const Duration(days: 6)))) {
      setState(() {
        _focusedWeekStart = newFocused;
      });
    }
  }

  bool _isSelectable(DateTime day) {
    if (day.isBefore(widget.allowedStart) || day.isAfter(widget.allowedEnd)) {
      return false;
    }
    for (var reservation in widget.reservations) {
      final checkIn = DateTime.parse(reservation.checkIn);
      final checkOut = DateTime.parse(reservation.checkOut);
      if (!day.isBefore(checkIn) && !day.isAfter(checkOut)) {
        return false;
      }
    }
    return true;
  }

  bool _isSelected(DateTime day) {
    if (_selectedStartDate == null) return false;
    if (_selectedEndDate == null) return day == _selectedStartDate;
    return !day.isBefore(_selectedStartDate!) && !day.isAfter(_selectedEndDate!);
  }

  void _onDayTapped(DateTime day) {
    if (!_isSelectable(day)) return;

    for (var reservation in widget.reservations) {
      final checkIn = DateTime.parse(reservation.checkIn);
      final checkOut = DateTime.parse(reservation.checkOut);
      if (!day.isBefore(checkIn) && !day.isAfter(checkOut)) {
        return;
      }
    }

    setState(() {
      if (_selectedStartDate == null || (_selectedStartDate != null && _selectedEndDate != null)) {
        _selectedStartDate = day;
        _selectedEndDate = null;
      } else if (_selectedStartDate != null && _selectedEndDate == null) {
        if (day.isBefore(_selectedStartDate!)) {
          _selectedStartDate = day;
        } else if (day.isAtSameMomentAs(_selectedStartDate!)) {
          _selectedEndDate = day;
        } else {
          _selectedEndDate = day;
        }
      }
    });

    if (_selectedStartDate != null && _selectedEndDate != null) {
      widget.onDateRangeSelected(_selectedStartDate!, _selectedEndDate!);
    } else if (_selectedStartDate != null && _selectedEndDate == null) {
      widget.onDateRangeSelected(_selectedStartDate!, _selectedStartDate!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final days = _getDaysInWeek();
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final onPrimaryColor = theme.colorScheme.onPrimary;
    final onSurfaceContainerHighestColor = theme.brightness == Brightness.light ? AppThemes.black_300 : AppThemes.black_900;
    final onSurfaceColor = theme.colorScheme.onSurface;

    final List<String> dynamicWeekdays = [];
    final List<String> weekdayLabels = ['Lu', 'Ma', 'Mi', 'Ju', 'Vi', 'Sa', 'Do'];
    int startIndex = _focusedWeekStart.weekday - 1; 
    for (int i = 0; i < 7; i++) {
      dynamicWeekdays.add(weekdayLabels[(startIndex + i) % 7]);
    }

    final capitalizedMonth = DateFormat('MMMM yyyy', 'es_ES').format(_focusedWeekStart);
    final capitalizedMonthFormatted = capitalizedMonth[0].toUpperCase() + capitalizedMonth.substring(1);

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
                  onPressed: _previousWeek,
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
                  onPressed: _nextWeek,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
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
                final isPast = day.isBefore(now.subtract(const Duration(days: 1)));
                final isSelectable = _isSelectable(day);
                final isSelected = _isSelected(day);

                return Material(
                  color: Colors.transparent,
                  child: Stack(
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: isSelectable ? () => _onDayTapped(day) : null,
                        child: Container(
                          width: 50,
                          height: 60,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? primaryColor
                                : isPast || !isSelectable
                                    ? onSurfaceContainerHighestColor.withValues(alpha: 0.3)
                                    : null,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: primaryColor,
                              width: 1.0,
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  day.day.toString(),
                                  style: TextStyle(
                                    color: isSelected
                                        ? onPrimaryColor
                                        : isPast || !isSelectable
                                            ? onSurfaceColor.withValues(alpha: 0.5)
                                            : primaryColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  dynamicWeekdays[index],
                                  style: TextStyle(
                                    color: (isSelected
                                            ? onPrimaryColor
                                            : isPast || !isSelectable
                                                ? onSurfaceColor.withValues(alpha: 0.5)
                                                : primaryColor)
                                        .withValues(alpha: 0.8),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (widget.reservations.any((reservation) {
                        final checkIn = DateTime.parse(reservation.checkIn);
                        final checkOut = DateTime.parse(reservation.checkOut);
                        return !day.isBefore(checkIn) && !day.isAfter(checkOut);
                      }))
                        Positioned(
                          right: 2,
                          top: 2,
                          child: Icon(
                            Icons.confirmation_num,
                            size: 12,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
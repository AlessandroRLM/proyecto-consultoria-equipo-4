import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/adapters/core/driven/app_themes.dart';

typedef DateRangeSelectedCallback = void Function(DateTime? start, DateTime? end);

class LodgingWeekCalendar extends StatefulWidget {
  final DateTime focusedWeekStart;
  final DateTime allowedStart;
  final DateTime allowedEnd;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final List<Map<String, dynamic>> reservations;
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
  LodgingWeekCalendarState createState() => LodgingWeekCalendarState();
}

class LodgingWeekCalendarState extends State<LodgingWeekCalendar> {
  late DateTime _focusedMonth;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime(widget.focusedWeekStart.year, widget.focusedWeekStart.month, 1);
    _selectedStartDate = widget.initialStartDate;
    _selectedEndDate = widget.initialEndDate;
  }

  List<DateTime> _getDaysInMonth() {
    final firstDayOfMonth = _focusedMonth;
    final startWeekday = firstDayOfMonth.weekday; // 1 = Monday
    final startDate = firstDayOfMonth.subtract(Duration(days: startWeekday - 1));
    List<DateTime> days = [];
    for (int i = 0; i < 35; i++) {
      days.add(startDate.add(Duration(days: i)));
    }
    return days;
  }

  void _previousMonth() {
    final newMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    final lastDayOfNewMonth = DateTime(newMonth.year, newMonth.month + 1, 0);
    if (!lastDayOfNewMonth.isBefore(widget.allowedStart) && !newMonth.isAfter(widget.allowedEnd)) {
      setState(() {
        _focusedMonth = newMonth;
      });
    }
  }

  void _nextMonth() {
    final newMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    if (!newMonth.isAfter(widget.allowedEnd) && !newMonth.isBefore(widget.allowedStart)) {
      setState(() {
        _focusedMonth = newMonth;
      });
    }
  }

  bool _isSelectable(DateTime day) {
    if (day.month != _focusedMonth.month || day.isBefore(widget.allowedStart) || day.isAfter(widget.allowedEnd)) {
      return false;
    }
    for (var reservation in widget.reservations) {
      final reservationInit = DateTime.parse(reservation['reservationInit']);
      final reservationFin = DateTime.parse(reservation['reservationFin']);
      if (!day.isBefore(reservationInit) && !day.isAfter(reservationFin)) {
        return false;
      }
    }
    return true;
  }

  bool _isReserved(DateTime day) {
    for (var reservation in widget.reservations) {
      final reservationInit = DateTime.parse(reservation['reservationInit']);
      final reservationFin = DateTime.parse(reservation['reservationFin']);
      if (!day.isBefore(reservationInit) && !day.isAfter(reservationFin)) {
        return true;
      }
    }
    return false;
  }

  bool _isSelected(DateTime day) {
    if (_selectedStartDate == null) return false;
    if (_selectedEndDate == null) return day == _selectedStartDate;
    return !day.isBefore(_selectedStartDate!) && !day.isAfter(_selectedEndDate!);
  }

  void _onDayTapped(DateTime day) {
    if (!_isSelectable(day)) return;

    for (var reservation in widget.reservations) {
      final reservationInit = DateTime.parse(reservation['reservationInit']);
      final reservationFin = DateTime.parse(reservation['reservationFin']);
      if (!day.isBefore(reservationInit) && !day.isAfter(reservationFin)) {
        return;
      }
    }

    if (_isSelected(day)) {
      setState(() {
        _selectedStartDate = null;
        _selectedEndDate = null;
      });
      widget.onDateRangeSelected(null, null);
      return;
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
    final days = _getDaysInMonth();
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final onPrimaryColor = theme.colorScheme.onPrimary;
    final onSurfaceContainerHighestColor = theme.brightness == Brightness.light ? AppThemes.black_300 : AppThemes.black_900;
    final onSurfaceColor = theme.colorScheme.onSurface;

    final List<String> weekdayLabels = ['Lu', 'Ma', 'Mi', 'Ju', 'Vi', 'Sa', 'Do'];

    final capitalizedMonth = DateFormat('MMMM yyyy', 'es_ES').format(_focusedMonth);
    final capitalizedMonthFormatted = capitalizedMonth[0].toUpperCase() + capitalizedMonth.substring(1);

    return LayoutBuilder(
      builder: (context, constraints) {
        double availableWidth = constraints.maxWidth;
        double rowPaddingHorizontal = availableWidth < 350 ? 16.0 : 32.0; 
        double dayPadding = availableWidth < 350 ? 2.0 : 8.0; 
        double effectiveDayWidth = (availableWidth - rowPaddingHorizontal) / 7 - dayPadding * 2;
        double dayHeight = effectiveDayWidth * (55.0 / 40.0);
        double fontSize = effectiveDayWidth > 35 ? 14.0 : (effectiveDayWidth > 30 ? 13.0 : 12.0);
        double smallFontSize = effectiveDayWidth > 35 ? 11.0 : (effectiveDayWidth > 30 ? 10.0 : 9.0);
        double iconSize = smallFontSize;

        List<Widget> rows = [];
        for (int row = 0; row < 5; row++) {
          List<Widget> rowWidgets = [];
          for (int col = 0; col < 7; col++) {
            final index = row * 7 + col;
            final day = days[index];
            final now = DateTime.now();
            final isPast = day.isBefore(now.subtract(const Duration(days: 1)));
            final isSelectable = _isSelectable(day);
            final isSelected = _isSelected(day);
            final isCurrentMonth = day.month == _focusedMonth.month;
            final weekdayAbbr = weekdayLabels[day.weekday - 1];
            final dayBoxWidth = effectiveDayWidth + dayPadding * 2;
            rowWidgets.add(
              SizedBox(
                width: dayBoxWidth,
                child: Padding(
                  padding: EdgeInsets.all(dayPadding),
                  child: Material(
                    color: Colors.transparent,
                    child: Stack(
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: isSelectable ? () => _onDayTapped(day) : null,
                          child: Container(
                            width: double.infinity,
                            height: dayHeight,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? primaryColor
                                  : !isCurrentMonth || isPast || (!isSelectable && !_isReserved(day))
                                      ? onSurfaceContainerHighestColor.withValues(alpha: 0.3)
                                      : null,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _isReserved(day) ? Colors.green : ((!isSelectable && !_isReserved(day)) ? onSurfaceColor.withValues(alpha: 0.3) : primaryColor),
                                width: 1.0,
                              ),
                            ),
                            child: Align(
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Text(
                                      day.day.toString(),
                                      style: TextStyle(
                                        color: isSelected
                                            ? onPrimaryColor
                                            : !isCurrentMonth || isPast || (!isSelectable && !_isReserved(day))
                                                ? onSurfaceColor.withValues(alpha: 0.5)
                                                : onSurfaceColor,
                                        fontWeight: FontWeight.w500,
                                        fontSize: fontSize,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Flexible(
                                    child: Text(
                                      weekdayAbbr,
                                      style: TextStyle(
                                        color: (isSelected
                                                ? onPrimaryColor
                                                : !isCurrentMonth || isPast || (!isSelectable && !_isReserved(day))
                                                    ? onSurfaceColor.withValues(alpha: 0.5)
                                                    : onSurfaceColor)
                                            .withValues(alpha: 0.8),
                                        fontSize: smallFontSize,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (isCurrentMonth && widget.reservations.any((reservation) {
                          final reservationInit = DateTime.parse(reservation['reservationInit']);
                          final reservationFin = DateTime.parse(reservation['reservationFin']);
                          return !day.isBefore(reservationInit) && !day.isAfter(reservationFin);
                        }))
                          Positioned(
                            right: availableWidth < 350 ? 1 : 2,
                            top: availableWidth < 350 ? 1 : 2,
                            child: Icon(
                              Icons.confirmation_num,
                              size: availableWidth < 350 ? iconSize * 0.8 : iconSize,
                              color: isSelected ? onPrimaryColor : Colors.green,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
          rows.add(
            Padding(
              padding: EdgeInsets.symmetric(horizontal: availableWidth < 350 ? 8.0 : 16.0),
              child: Row(
                children: rowWidgets,
              ),
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: availableWidth < 350 ? 8.0 : 16.0),
              child: SizedBox(
                height: 48,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.chevron_left, color: primaryColor.withValues(alpha: 0.3)),
                      onPressed: _previousMonth,
                    ),
                    Expanded(
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            capitalizedMonthFormatted,
                            style: TextStyle(
                              fontSize: availableWidth < 350 ? 16.0 : 18.0,
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.chevron_right, color: primaryColor.withValues(alpha: 0.3)),
                      onPressed: _nextMonth,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: availableWidth < 350 ? 8.0 : 16.0),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: rows,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
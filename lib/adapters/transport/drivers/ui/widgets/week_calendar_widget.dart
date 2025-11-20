import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/adapters/transport/driven/providers/transport_reservations_provider.dart';

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
                    final isReserved = isOutbound ? transportProvider.hasOutboundOnDate(dateStr) : transportProvider.hasReturnOnDate(dateStr);
                    
                    final isSelected = selectedDate != null && selectedDate!.isAtSameMomentAs(day);
                    final isSelectable = !isPast && !day.isBefore(allowedStart!) && !day.isAfter(allowedEnd!);
                    final isHighlighted = isSelected;
                    return Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                            onTap: () => onDaySelected(day),
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
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransportCalendarScreen extends StatefulWidget {
  const TransportCalendarScreen({super.key});

  @override
  State<TransportCalendarScreen> createState() => _TransportCalendarScreenState();
}

class _TransportCalendarScreenState extends State<TransportCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final List<String> _weekdays = ['Lu', 'Ma', 'Mi', 'Ju', 'Vi', 'Sa', 'Do'];

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

    final remainingDays = 42 - days.length; 
    for (int i = 1; i <= remainingDays; i++) {
      days.add(DateTime(month.year, month.month + 1, i));
    }

    return days;
  }

  void _previousMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
      _selectedDay = null; 
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
      _selectedDay = null; 
    });
  }

  void _onDaySelected(DateTime day) {
    setState(() {
      _selectedDay = day;
    });
  }

  @override
  Widget build(BuildContext context) {
    final days = _getDaysInMonth(_focusedDay);
    final monthName = DateFormat('MMMM', 'es_ES').format(_focusedDay);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservar'),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        elevation: 1,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          const Text(
            'Seleccione la fecha del alojamiento',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.black54),
                  onPressed: _previousMonth,
                ),
                Text(
                  '$monthName ${_focusedDay.year}',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.black54),
                  onPressed: _nextMonth,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1.2,
                ),
                itemCount: days.length,
                itemBuilder: (context, index) {
                  final day = days[index];
                  final isCurrentMonth = day.month == _focusedDay.month;
                  final isSelected = _selectedDay != null && day.isAtSameMomentAs(_selectedDay!);
                  final weekday = _weekdays[index % 7];

                  return GestureDetector(
                    onTap: isCurrentMonth ? () => _onDaySelected(day) : null,
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isCurrentMonth ? Colors.red : Colors.grey.shade300,
                          width: 1.5,
                        ),
                        color: isSelected ? Colors.red.shade100 : Colors.transparent,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            day.day.toString(),
                            style: TextStyle(
                              color: isCurrentMonth ? Colors.red : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            weekday,
                            style: TextStyle(
                              color: isCurrentMonth ? Colors.red : Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mobile/adapters/lodging/drivers/ui/widgets/lodging_week_calendar.dart';
import 'package:provider/provider.dart';
import 'package:mobile/adapters/lodging/driven/providers/lodging_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/adapters/core/driven/app_themes.dart';

class LodgingCalendarScreen extends StatefulWidget {
  final String selectedLocation;

  const LodgingCalendarScreen({super.key, required this.selectedLocation});

  @override
  State<LodgingCalendarScreen> createState() => _LodgingCalendarScreenState();
}

class _LodgingCalendarScreenState extends State<LodgingCalendarScreen> {
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  String formatDate(DateTime date) {
    final weekdays = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    final months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    final weekday = weekdays[date.weekday - 1];
    final day = date.day;
    final month = months[date.month - 1];
    return "$weekday $day de $month";
  }

  @override
  Widget build(BuildContext context) {
    final lodgingProvider = Provider.of<LodgingProvider>(context, listen: false);
    final minSelectableDate = lodgingProvider.getMinReservableDate();
    final maxSelectableDate = minSelectableDate.add(const Duration(days: 365));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservar'),
      ),
      body: GestureDetector(
        onTap: () {
          setState(() {
            _selectedStartDate = null;
            _selectedEndDate = null;
          });
        },
        child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Seleccione la fecha del alojamiento',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: LodgingWeekCalendar(
                focusedWeekStart: minSelectableDate,
                allowedStart: minSelectableDate,
                allowedEnd: maxSelectableDate,
                initialStartDate: _selectedStartDate,
                initialEndDate: _selectedEndDate,
                reservations: Provider.of<LodgingProvider>(context).reservations,
                onDateRangeSelected: (start, end) {
                  setState(() {
                    _selectedStartDate = start;
                    _selectedEndDate = end;
                  });
                },
              ),
            ),
          ),
          if (_selectedStartDate != null && _selectedEndDate != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'De ${formatDate(_selectedStartDate!)} a ${formatDate(_selectedEndDate!)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ReservationButtonWidget(
            selectedLocation: widget.selectedLocation,
            selectedStartDate: _selectedStartDate,
            selectedEndDate: _selectedEndDate,
            onReserve: () {
              if (_selectedStartDate != null && _selectedEndDate != null) {
                final lodgingProvider = Provider.of<LodgingProvider>(context, listen: false);
                lodgingProvider.addReservation({
                  'area': widget.selectedLocation,
                  'name': widget.selectedLocation,
                  'address': '',
                  'room': '',
                  'checkIn': _selectedStartDate!.toIso8601String(),
                  'checkOut': _selectedEndDate!.toIso8601String(),
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Reserva confirmada para el ${formatDate(_selectedStartDate!)} hasta ${formatDate(_selectedEndDate!)}'),
                  ),
                );
                context.go('/lodging');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Por favor, selecciona fechas para reservar'),
                  ),
                );
              }
            },
          ),
        ],
      ),
    ),
  );
  }
}

class ReservationButtonWidget extends StatelessWidget {
  final String selectedLocation;
  final DateTime? selectedStartDate;
  final DateTime? selectedEndDate;
  final VoidCallback onReserve;

  const ReservationButtonWidget({
    super.key,
    required this.selectedLocation,
    required this.selectedStartDate,
    required this.selectedEndDate,
    required this.onReserve,
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
            color: theme.shadowColor.withValues(alpha: 0.05),
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
                  'Alojamiento',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                if (selectedLocation.isNotEmpty)
                  Text(
                    selectedLocation,
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
              onPressed: selectedStartDate != null && selectedEndDate != null ? onReserve : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedStartDate != null && selectedEndDate != null ? AppThemes.primary_600 : theme.colorScheme.onSurface.withValues(alpha: 0.5),
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

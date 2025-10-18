import 'package:flutter/material.dart';
import 'package:mobile/adapters/lodging/drivers/ui/widgets/lodging_week_calendar.dart';
import 'package:provider/provider.dart';
import 'package:mobile/adapters/lodging/driven/providers/lodging_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/adapters/core/driven/app_themes.dart';
import 'package:mobile/domain/models/lodging/lodging_reservation_model.dart';

class LodgingCalendarScreen extends StatefulWidget {
  final String selectedLocation;
  final String address;
  final String city;
  final String residenceName;

  const LodgingCalendarScreen({
    super.key,
    required this.selectedLocation,
    required this.address,
    required this.city,
    required this.residenceName,
  });

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
    final year = date.year;
    return "$weekday $day de $month de $year";
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final minSelectableDate = today.add(const Duration(days: 7));
    final maxSelectableDate = minSelectableDate.add(const Duration(days: 365));

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const SizedBox.shrink(),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedStartDate = null;
              _selectedEndDate = null;
            });
          },
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 8.0, 16.0, 0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () => context.pop(),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Reservar',
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
                        'Seleccione la fecha del alojamiento',
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: LodgingWeekCalendar(
                            focusedWeekStart: minSelectableDate,
                            allowedStart: minSelectableDate,
                            allowedEnd: maxSelectableDate,
                            initialStartDate: _selectedStartDate,
                            initialEndDate: _selectedEndDate,
                            reservations: Provider.of<LodgingProvider>(context).occupiedReservations.where((r) => r['area'] == widget.selectedLocation).toList(),
                            onDateRangeSelected: (start, end) {
                              setState(() {
                                _selectedStartDate = start;
                                _selectedEndDate = end;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),

              Positioned(
                left: 0,
                right: 0,
                bottom: 12,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ReservationButtonWidget(
                    selectedLocation: widget.selectedLocation,
                    selectedStartDate: _selectedStartDate,
                    selectedEndDate: _selectedEndDate,
                    onReserve: () {
                      if (_selectedStartDate != null && _selectedEndDate != null) {
                        final lodgingProvider = Provider.of<LodgingProvider>(context, listen: false);
                        lodgingProvider.addReservation(LodgingReservation.fromJson({
                          'area': widget.selectedLocation,
                          'name': widget.residenceName,
                          'address': widget.address,
                          'room': '',
                          'checkIn': _selectedStartDate!.toIso8601String(),
                          'checkOut': _selectedEndDate!.toIso8601String(),
                        }));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Reserva confirmada'),
                                  Text('Desde: ${formatDate(_selectedStartDate!)}'),
                                  Text('Hasta: ${formatDate(_selectedEndDate!)}'),
                                ],
                              ),
                            ),
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
                ),
              ),
            ],
          ),
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final buttonWidth = width * (width < 360 ? 0.36 : 0.28);
        final cardColor = theme.colorScheme.surface;
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
          color: cardColor,
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: buttonWidth.clamp(86.0, 160.0),
                height: 40,
                child: ElevatedButton(
                  onPressed: selectedStartDate != null && selectedEndDate != null ? onReserve : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(buttonWidth, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    backgroundColor: selectedStartDate != null && selectedEndDate != null ? AppThemes.primary_600 : theme.colorScheme.onSurface.withValues(alpha: 0.12),
                    foregroundColor: selectedStartDate != null && selectedEndDate != null ? Colors.white : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Reservar',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

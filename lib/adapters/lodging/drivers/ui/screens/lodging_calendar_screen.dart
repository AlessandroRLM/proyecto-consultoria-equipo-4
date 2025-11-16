import 'package:flutter/material.dart';
import 'package:mobile/adapters/lodging/drivers/ui/widgets/lodging_week_calendar.dart';
import 'package:mobile/domain/models/lodging/estado_agenda.dart';
import 'package:provider/provider.dart';
import 'package:mobile/adapters/lodging/driven/providers/lodging_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/adapters/core/driven/app_themes.dart';
import 'package:mobile/domain/models/lodging/agenda_model.dart';

class LodgingCalendarScreen extends StatefulWidget {

  const LodgingCalendarScreen({super.key,});

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
    final lodgingProvider = Provider.of<LodgingProvider>(context, listen: false);
    final selectedClinic = Provider.of<LodgingProvider>(context).selectedClinic;
    if (selectedClinic == null) {
    return Scaffold(
      body: Center(child: Text('No se ha seleccionado ninguna clínica')),
    );
}

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
                            reservations: lodgingProvider.occupiedReservations.where((r) => r['area'] == selectedClinic.name).toList(),
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
                    selectedLocation: selectedClinic.name,
                    selectedStartDate: _selectedStartDate,
                    selectedEndDate: _selectedEndDate,
                    onReserve: () {
                      if (_selectedStartDate != null && _selectedEndDate != null) {
                        final selectedClinic = lodgingProvider.selectedClinic;

                        if (selectedClinic == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No hay clínica seleccionada')),
                          );
                          return;
                        }

                        final now = DateTime.now();
                        final reservation = AgendaModel(
                          id: DateTime.now().millisecondsSinceEpoch, 
                          studentId: 1,
                          occupantName: 'Estudiante', 
                          occupantMobile: '000000000', 
                          occupantKind: 'Interno',
                          reservationDate: "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}",
                          reservationInit: "${_selectedStartDate!.hour.toString().padLeft(2, '0')}:${_selectedStartDate!.minute.toString().padLeft(2, '0')}",
                          reservationFin: "${_selectedEndDate!.hour.toString().padLeft(2, '0')}:${_selectedEndDate!.minute.toString().padLeft(2, '0')}",
                          clinicalName: selectedClinic.name,
                          homeId: selectedClinic.id,
                          state: EstadoAgenda.pendiente // o el estado que corresponda
                        );

                        lodgingProvider.addReservation(reservation);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Reserva confirmada'),
                                  Text('Clínica: ${selectedClinic.name}'),
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
                          const SnackBar(content: Text('Por favor, selecciona fechas para reservar')),
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

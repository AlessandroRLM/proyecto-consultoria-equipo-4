import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/lodging/providers/lodging_provider.dart';
import 'package:provider/provider.dart';

class LodgingReservationScreen extends StatefulWidget {
  const LodgingReservationScreen({super.key});

  @override
  State<LodgingReservationScreen> createState() =>
      _LodgingReservationScreenState();
}

class _LodgingReservationScreenState extends State<LodgingReservationScreen> {
  DateTimeRange? selectedDates;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reservar alojamiento")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Nombre del lugar"),
            ),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: "Dirección"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final now = DateTime.now();
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: now,
                  lastDate: DateTime(now.year, now.month + 3, now.day),
                );
                if (picked != null) {
                  setState(() {
                    selectedDates = picked;
                  });
                }
              },
              child: Text(
                selectedDates == null
                    ? "Seleccionar fechas"
                    : "Del ${selectedDates!.start.day}/${selectedDates!.start.month} "
                          "al ${selectedDates!.end.day}/${selectedDates!.end.month}",
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed:
                  selectedDates == null ||
                      _nameController.text.isEmpty ||
                      _addressController.text.isEmpty
                  ? null
                  : () {
                      context.read<LodgingProvider>().addReservation(
                        LodgingReservation(
                          name: _nameController.text,
                          address: _addressController.text,
                          startDate: selectedDates!.start,
                          endDate: selectedDates!.end,
                        ),
                      );
                      context.go('/lodging');
                    },
              child: const Text("Confirmar reserva"),
            ),
          ],
        ),
      ),
    );
  }
}

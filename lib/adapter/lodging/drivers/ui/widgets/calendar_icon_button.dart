import 'package:flutter/material.dart';
import 'package:mobile/adapter/core/out/app_themes.dart';

class CalendarIconButton extends StatelessWidget {
  final Function(DateTime) onDateSelected;

  const CalendarIconButton({super.key, required this.onDateSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        width: 80,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppThemes.primary_600),
          borderRadius: BorderRadius.circular(18),
        ),
        child: IconButton(
          onPressed: () async {
            DateTime? selectedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2023),
              lastDate: DateTime(2030),
            );

            if (selectedDate != null) {
              onDateSelected(selectedDate);
            }
          },
          icon: const Icon(Icons.calendar_today),
          color: AppThemes.primary_600,
        ),
      ),
    );
  }
}

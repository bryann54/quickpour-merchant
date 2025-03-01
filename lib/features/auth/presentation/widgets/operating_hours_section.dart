// lib/features/auth/presentation/widgets/operating_hours_section.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickpourmerchant/core/utils/time_range_utils.dart';

class OperatingHoursSection extends StatelessWidget {
  final bool is24Hours;
  final StoreHours? storeHours;
  final Function(bool) onUpdate24Hours;
  final Function(StoreHours?) onUpdateStoreHours;

  const OperatingHoursSection({
    Key? key,
    required this.is24Hours,
    required this.storeHours,
    required this.onUpdate24Hours,
    required this.onUpdateStoreHours,
  }) : super(key: key);

  Future<void> _selectTimeRange(BuildContext context) async {
    if (is24Hours) return;

    final TimeOfDay? openingTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      helpText: 'Select Opening Time',
    );

    if (openingTime != null) {
      final TimeOfDay? closingTime = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 17, minute: 0),
        helpText: 'Select Closing Time',
      );

      if (closingTime != null) {
        onUpdateStoreHours(
          StoreHours(opening: openingTime, closing: closingTime),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          'Operating Hours',
          style: GoogleFonts.acme(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            Checkbox(
              value: is24Hours,
              onChanged: (value) => onUpdate24Hours(value ?? false),
            ),
            const Text('24 Hours'),
          ],
        ),
        if (!is24Hours) ...[
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _selectTimeRange(context),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    storeHours?.getDisplayText() ?? 'Select Operating Hours',
                    style: TextStyle(
                      color: storeHours == null
                          ? Colors.grey
                          : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const Icon(Icons.access_time),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PromotionDetails extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final String promotionType;
  final bool isActive;
  final Function(DateTime) onStartDateChanged;
  final Function(DateTime) onEndDateChanged;
  final Function(String) onPromotionTypeChanged;
  final Function(bool) onActiveStatusChanged;

  const PromotionDetails({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.promotionType,
    required this.isActive,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    required this.onPromotionTypeChanged,
    required this.onActiveStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Promotion Details',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDateSelector(
                context: context, // Pass context here
                title: 'Start Date',
                selectedDate: startDate,
                onSelect: onStartDateChanged,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDateSelector(
                context: context, // Pass context here
                title: 'End Date',
                selectedDate: endDate,
                onSelect: onEndDateChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: promotionType,
          decoration: const InputDecoration(
            labelText: 'Promotion Type',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'flash_sale', child: Text('Flash Sale')),
            DropdownMenuItem(value: 'seasonal', child: Text('Seasonal')),
            DropdownMenuItem(value: 'clearance', child: Text('Clearance')),
            DropdownMenuItem(value: 'bundle', child: Text('Bundle Deal')),
            DropdownMenuItem(value: 'holiday', child: Text('Holiday Special')),
          ],
          onChanged: (value) => onPromotionTypeChanged(value!),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Active Status'),
          subtitle: const Text('Enable or disable this promotion'),
          value: isActive,
          onChanged: onActiveStatusChanged,
        ),
      ],
    );
  }

  Widget _buildDateSelector({
    required BuildContext context, // Add context as a required parameter
    required String title,
    required DateTime selectedDate,
    required Function(DateTime) onSelect,
  }) {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context, // Use the passed context
          initialDate: selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) onSelect(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: title,
          border: const OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat('MMM dd, yyyy').format(selectedDate)),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }
}

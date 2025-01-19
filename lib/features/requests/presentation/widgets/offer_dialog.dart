import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:quickpourmerchant/features/auth/domain/usecases/auth_usecases.dart';
import 'package:quickpourmerchant/features/requests/data/models/drink_request_model.dart';
import 'package:quickpourmerchant/features/requests/data/repositories/drink_request_repo.dart';
import 'package:quickpourmerchant/features/auth/data/repositories/auth_repository.dart';

class OfferDialog extends StatefulWidget {
  final DrinkRequest request;

  const OfferDialog({
    Key? key,
    required this.request,
  }) : super(key: key);

  @override
  State<OfferDialog> createState() => _OfferDialogState();
}

class _OfferDialogState extends State<OfferDialog> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  DateTime? _selectedDeliveryTime;
  String? _additionalNotes;
  bool _isLoading = false;

  String? _storeName;
  String? _location;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    final authUseCases = AuthUseCases(authRepository: AuthRepository());
    final currentUser = await authUseCases.getCurrentUserDetails();

    if (currentUser != null) {
      setState(() {
        _storeName = currentUser.storeName;
        _location = currentUser.location;
      });
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _selectDeliveryTime(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDateTimePicker(
      context: context,
      initialDate: now.add(const Duration(minutes: 30)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 7)),
    );

    if (picked != null) {
      setState(() {
        _selectedDeliveryTime = picked;
      });
    }
  }

  void _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();

      setState(() => _isLoading = true);

      try {
        final repository = DrinkRequestRepository();

        await repository.submitOffer(
          requestId: widget.request.id,
          price: double.parse(_priceController.text),
          deliveryTime: _selectedDeliveryTime!,
          notes: _additionalNotes,
          storeName: _storeName.toString(), 
          location: _location.toString(), 
        );

        if (mounted) {
          Navigator.of(context).pop(); // Close dialog on success
        }
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting offer: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Make an Offer',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Request Summary
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.request.quantity}x ${widget.request.drinkName}',
                        style: theme.textTheme.titleMedium,
                      ),
                      if (widget.request.additionalInstructions.isNotEmpty)
                        Text(
                          widget.request.additionalInstructions,
                          style: theme.textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Price Input
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: 'Total Price',
                    prefixText: '\Ksh',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price';
                    }
                    final price = double.tryParse(value);
                    if (price == null || price <= 0) {
                      return 'Please enter a valid price';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Delivery Time Selector
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    _selectedDeliveryTime == null
                        ? 'Select Delivery Time'
                        : 'Delivery Time: ${DateFormat('MMM d, h:mm a').format(_selectedDeliveryTime!)}',
                  ),
                  trailing: Icon(
                    Icons.schedule,
                    color: theme.colorScheme.primary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: theme.dividerColor),
                  ),
                  onTap: () => _selectDeliveryTime(context),
                ),
                const SizedBox(height: 16),

                // Additional Notes
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Additional Notes (Optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                  onSaved: (value) => _additionalNotes = value,
                ),
                const SizedBox(height: 24),

                // Submit Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Submit Offer'),
                ),
                const SizedBox(height: 8),

                // Cancel Button
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Helper function to show date and time picker
Future<DateTime?> showDateTimePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) async {
  final DateTime? date = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
  );
  if (date == null) return null;

  final TimeOfDay? time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(initialDate),
  );
  if (time == null) return null;

  return DateTime(
    date.year,
    date.month,
    date.day,
    time.hour,
    time.minute,
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:quickpourmerchant/features/promotions/data/models/promotion_model.dart';
import 'package:quickpourmerchant/features/promotions/presentation/bloc/promotions_bloc.dart';
import 'package:quickpourmerchant/features/promotions/presentation/bloc/promotions_event.dart';

class EditPromotionDialog extends StatefulWidget {
  final MerchantPromotionModel promotion;

  const EditPromotionDialog({
    super.key,
    required this.promotion,
  });

  @override
  State<EditPromotionDialog> createState() => _EditPromotionDialogState();
}

class _EditPromotionDialogState extends State<EditPromotionDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _productIdController;
  late TextEditingController _discountController;
  late TextEditingController _descriptionController;
  late DateTime _startDate;
  late DateTime _endDate;
  late String _promotionType;
  late bool _isActive;

  @override
  void initState() {
    super.initState();

    _discountController = TextEditingController(
        text: widget.promotion.discountPercentage.toString());
    _descriptionController =
        TextEditingController(text: widget.promotion.description);
    _startDate = widget.promotion.startDate;
    _endDate = widget.promotion.endDate;
    _promotionType = widget.promotion.promotionType;
    _isActive = widget.promotion.isActive;
  }

  @override
  void dispose() {
    _productIdController.dispose();
    _discountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Promotion'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _productIdController,
                decoration: const InputDecoration(labelText: 'Product ID'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product ID';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _discountController,
                decoration:
                    const InputDecoration(labelText: 'Discount Percentage'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter discount percentage';
                  }
                  final discount = double.tryParse(value);
                  if (discount == null || discount <= 0 || discount > 100) {
                    return 'Please enter a valid discount (1-100)';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Start Date'),
                      subtitle:
                          Text(DateFormat('MMM dd, yyyy').format(_startDate)),
                      onTap: () => _selectDate(context, true),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('End Date'),
                      subtitle:
                          Text(DateFormat('MMM dd, yyyy').format(_endDate)),
                      onTap: () => _selectDate(context, false),
                    ),
                  ),
                ],
              ),
              DropdownButtonFormField<String>(
                value: _promotionType,
                decoration: const InputDecoration(labelText: 'Promotion Type'),
                items: const [
                  DropdownMenuItem(
                      value: 'flash_sale', child: Text('Flash Sale')),
                  DropdownMenuItem(value: 'seasonal', child: Text('Seasonal')),
                  DropdownMenuItem(
                      value: 'clearance', child: Text('Clearance')),
                ],
                onChanged: (value) {
                  setState(() {
                    _promotionType = value!;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Active'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final updatedPromotion = widget.promotion.copyWith(
        discountPercentage: double.parse(_discountController.text),
        startDate: _startDate,
        endDate: _endDate,
        isActive: _isActive,
        description: _descriptionController.text,
        promotionType: _promotionType,
      );

      context.read<PromotionsBloc>().add(UpdatePromotion(updatedPromotion));
      Navigator.pop(context);
    }
  }
}

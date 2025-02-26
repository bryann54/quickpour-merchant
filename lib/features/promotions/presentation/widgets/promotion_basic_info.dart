import 'package:flutter/material.dart';

class PromotionBasicInfo extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController discountController;
  final TextEditingController descriptionController;

  const PromotionBasicInfo({
    super.key,
    required this.titleController,
    required this.discountController,
    required this.descriptionController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Basic Information',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: 'Campaign Title',
            border: OutlineInputBorder(),
            hintText: 'Enter campaign title',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter campaign title';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: discountController,
          decoration: const InputDecoration(
            labelText: 'Discount Percentage',
            border: OutlineInputBorder(),
            suffixText: '%',
            hintText: 'Enter discount percentage',
          ),
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
        const SizedBox(height: 16),
        TextFormField(
          controller: descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description',
            border: OutlineInputBorder(),
            hintText: 'Enter promotion description',
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter description';
            }
            return null;
          },
        ),
      ],
    );
  }
}

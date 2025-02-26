import 'package:flutter/material.dart';
import 'package:quickpourmerchant/features/promotions/data/models/promotion_model.dart';

class PromotionTargetSelector extends StatelessWidget {
  final PromotionTarget promotionTarget;
  final Function(PromotionTarget) onTargetChanged;

  const PromotionTargetSelector({
    super.key,
    required this.promotionTarget,
    required this.onTargetChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Promotion Target',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<PromotionTarget>(
          value: promotionTarget,
          decoration: const InputDecoration(
            labelText: 'Promotion Target',
            border: OutlineInputBorder(),
          ),
          items: PromotionTarget.values.map((target) {
            return DropdownMenuItem(
              value: target,
              child: Text(target.toString().split('.').last.toUpperCase()),
            );
          }).toList(),
          onChanged: (value) => onTargetChanged(value!),
        ),
      ],
    );
  }
}

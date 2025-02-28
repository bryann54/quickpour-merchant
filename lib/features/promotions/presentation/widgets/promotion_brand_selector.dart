import 'package:flutter/material.dart';
import 'package:quickpourmerchant/features/brands/data/models/brands_model.dart';

class PromotionBrandSelector extends StatelessWidget {
  final List<String> selectedBrands;
  final List<BrandModel> brands;
  final Function(String, bool) onBrandSelected;
  final String merchantId;

  const PromotionBrandSelector({
    super.key,
    required this.selectedBrands,
    required this.brands,
    required this.onBrandSelected,
    required this.merchantId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Brands',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: brands.map((brand) {
            return FilterChip(
              label: Text(brand.name),
              selected: selectedBrands.contains(brand.id),
              onSelected: (selected) => onBrandSelected(brand.id, selected),
              avatar: CircleAvatar(
                backgroundImage: NetworkImage(brand.logoUrl),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

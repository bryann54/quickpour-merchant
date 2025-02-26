import 'package:flutter/material.dart';
import 'package:quickpourmerchant/features/categories/domain/entities/category.dart';

class PromotionCategorySelector extends StatelessWidget {
  final List<String> selectedCategories;
  final List<Category> categories;
  final Function(String, bool) onCategorySelected;

  const PromotionCategorySelector({
    super.key,
    required this.selectedCategories,
    required this.categories,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Categories',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((category) {
            return FilterChip(
              label: Text(category.name),
              selected: selectedCategories.contains(category.id),
              onSelected: (selected) =>
                  onCategorySelected(category.id, selected),
              avatar: CircleAvatar(
                backgroundImage: NetworkImage(category.imageUrl),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:quickpourmerchant/core/utils/colors.dart';
import 'package:quickpourmerchant/features/categories/domain/entities/category.dart';
import 'package:quickpourmerchant/features/categories/presentation/widgets/category_card.dart';

class HorizontalCategoriesListWidget extends StatelessWidget {
  final List<Category> categories;

  const HorizontalCategoriesListWidget({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isDarkMode
                ? AppColors.dividerColorDark.withOpacity(0.2)
                : AppColors.cardColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: categories.isEmpty
                ? Center(
                    child: Text(
                      'No categories available',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : GridView.count(
                    shrinkWrap: true, // Prevents the grid from scrolling
                    physics:
                        const NeverScrollableScrollPhysics(), // Disables scrolling
                    crossAxisCount: 3,
                    crossAxisSpacing: 28,
                    mainAxisSpacing: 1, 
                    childAspectRatio: 1,
                    children: List.generate(
                      categories.length > 6 ? 6 : categories.length,
                      (index) => CategoryCard(
                        category: categories[index],
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

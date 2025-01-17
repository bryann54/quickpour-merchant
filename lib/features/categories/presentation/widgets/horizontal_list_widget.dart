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
        Container(
          decoration: BoxDecoration(
            color: isDarkMode
                ? AppColors.dividerColorDark.withOpacity(0.2)
                : AppColors.cardColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: categories.isEmpty
                ? Expanded(
                    child: SizedBox(
                      height: 50, // Minimal height for the empty state
                      child: Center(
                        child: Text(
                          'No categories available',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  )
                : GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 8,
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

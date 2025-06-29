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
    final screenSize = MediaQuery.of(context).size;

    // Calculate dynamic cross axis count based on screen width
    int crossAxisCount = (screenSize.width / 120).floor();
    // Ensure minimum of 2 and maximum of 4 items per row
    crossAxisCount = crossAxisCount.clamp(2, 4);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          constraints: const BoxConstraints(
              maxHeight: 300), // Adjust max height as needed
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? AppColors.dividerColorDark.withValues(alpha: 0.2)
                        : AppColors.cardColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: categories.isEmpty
                        ? _buildEmptyState(theme)
                        : _buildCategoriesGrid(
                            crossAxisCount: crossAxisCount,
                            constraints: constraints,
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return SizedBox(
      height: 50,
      child: Center(
        child: Text(
          'No categories available',
          style: theme.textTheme.bodySmall?.copyWith(
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid({
    required int crossAxisCount,
    required BoxConstraints constraints,
  }) {
    // Calculate optimal aspect ratio based on available width and height
    final double aspectRatio = (constraints.maxWidth / crossAxisCount) /
        ((constraints.maxHeight - 16) / 2); // -16 for padding

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8,
        mainAxisSpacing: 5,
        childAspectRatio: aspectRatio.clamp(1.0, 1.5),
      ),
      itemCount: categories.length > 6 ? 6 : categories.length,
      itemBuilder: (context, index) => CategoryCard(
        category: categories[index],
      ),
    );
  }
}

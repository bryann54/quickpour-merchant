import 'package:flutter/material.dart';
import 'package:quickpourmerchant/features/auth/data/repositories/auth_repository.dart';
import 'package:quickpourmerchant/features/auth/domain/usecases/auth_usecases.dart';

class AnalyticsScreen extends StatefulWidget {
  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String selectedTimeFilter = '90 Days';
  String userName = '';

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    final authRepository = AuthRepository(); 
    final authUseCases = AuthUseCases(authRepository: authRepository);
    final user = await authUseCases.getCurrentUserDetails();
    setState(() {
      userName = user?.storeName ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          userName,
          style: theme.textTheme.displayLarge?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'View overall statistics of the last',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            // Time Filter Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['7 Days', '30 Days', '90 Days', 'Custom']
                  .map((label) => ChoiceChip(
                        label: Text(label),
                        selected: label == selectedTimeFilter,
                        selectedColor: theme.colorScheme.primary,
                        onSelected: (selected) {
                          setState(() {
                            selectedTimeFilter = label;
                          });
                        },
                        backgroundColor: theme.colorScheme.surfaceVariant,
                        labelStyle: TextStyle(
                          color: label == selectedTimeFilter
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            // Statistics Cards
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildStatCard(
                    context,
                    'In Stock',
                    '4,398',
                    Icons.inventory,
                    theme.colorScheme.primary,
                  ),
                  _buildStatCard(
                    context,
                    'Orders',
                    '2,512',
                    Icons.shopping_cart,
                    theme.colorScheme.secondary,
                    percentage: '13%',
                    isIncrease: true,
                  ),
                  _buildStatCard(
                    context,
                    'Feedback',
                    '3.6k',
                    Icons.thumb_up,
                    theme.colorScheme.tertiary,
                    percentage: '13%',
                    isIncrease: false,
                  ),
                  _buildStatCard(
                    context,
                    'Reviews',
                    '2.6k',
                    Icons.reviews,
                    theme.colorScheme.error,
                    percentage: '1.2%',
                    isIncrease: true,
                    extraInfo: '233 ASINs',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // My Workflow Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.bar_chart, color: theme.colorScheme.secondary),
                      const SizedBox(width: 8),
                      Text(
                        'My Workflow',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "You don’t have any Workflows running. Create a Workflow in order to view its insights here.",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle button press
                      },
                      child: const Text('Create a Workflow'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color, {
    String? percentage,
    bool? isIncrease,
    String? extraInfo,
  }) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.displayLarge?.copyWith(
              fontSize: 24,
            ),
          ),
          if (percentage != null)
            Row(
              children: [
                Icon(
                  isIncrease == true
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                  color: isIncrease == true
                      ? theme.colorScheme.primary
                      : theme.colorScheme.error,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  percentage,
                  style: TextStyle(
                    color: isIncrease == true
                        ? theme.colorScheme.primary
                        : theme.colorScheme.error,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          if (extraInfo != null)
            Text(
              extraInfo,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
        ],
      ),
    );
  }
}

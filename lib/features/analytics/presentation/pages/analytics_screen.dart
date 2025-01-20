import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickpourmerchant/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:quickpourmerchant/features/analytics/presentation/widgets/stat_card.dart';
import 'package:quickpourmerchant/features/analytics/presentation/widgets/workflow_card.dart';
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
            BlocBuilder<AnalyticsBloc, AnalyticsState>(
              builder: (context, state) {
                if (state is AnalyticsLoading) {
                  return const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (state is AnalyticsError) {
                  return Expanded(
                    child: Center(child: Text(state.message)),
                  );
                } else if (state is AnalyticsLoaded) {
                  return Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.78,
                            children: [
                              StatCard(
                                title: 'In Stock',
                                value: state.stockCount.toString(),
                                icon: Icons.inventory,
                                color: theme.colorScheme.primary,
                              ),
                              StatCard(
                                title: 'Orders',
                                value: state.ordersCount.toString(),
                                icon: Icons.shopping_cart,
                                color: theme.colorScheme.secondary,
                                percentage: '13%',
                                isIncrease: true,
                              ),
                              StatCard(
                                title: 'Feedback',
                                value: state.feedbackCount.toString(),
                                icon: Icons.thumb_up,
                                color: theme.colorScheme.tertiary,
                                percentage: '13%',
                                isIncrease: false,
                              ),
                              StatCard(
                                title: 'Reviews',
                                value: '2.6k',
                                icon: Icons.reviews,
                                color: theme.colorScheme.error,
                                percentage: '1.2%',
                                isIncrease: true,
                                extraInfo: '233 ASINs',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        WorkflowCard(
                          onCreateWorkflow: () {
                            // Handle creating a workflow
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  );
                }
                return Container();
              },
            ),
          ],
        ),
      ),
    );
  }
}

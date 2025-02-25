import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quickpourmerchant/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:quickpourmerchant/features/auth/data/repositories/auth_repository.dart';
import 'package:quickpourmerchant/features/auth/domain/usecases/auth_usecases.dart';

class StatCardDetailView extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? percentage;
  final bool? isIncrease;
  final String? extraInfo;

  const StatCardDetailView({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.percentage,
    this.isIncrease,
    this.extraInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Hero(
            tag: 'stat_card_$title',
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: double.infinity,
                height: 300,
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
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(icon, color: color, size: 32),
                        const SizedBox(width: 16),
                        Text(
                          title,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      value,
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontSize: 48,
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
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            percentage!,
                            style: TextStyle(
                              color: isIncrease == true
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.error,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    if (extraInfo != null)
                      Text(
                        extraInfo!,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    const Spacer(),
                    Text(
                      'Detailed Statistics',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap anywhere to close',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
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

    context.read<AnalyticsBloc>().add(FetchAnalyticsData());
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
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'View overall statistics of the last:',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['7 Days', '30 Days', '90 Days', 'Custom']
                  .map((label) => Expanded(
                        child: ChoiceChip(
                          label: Text(label),
                          selected: label == selectedTimeFilter,
                          selectedColor: theme.colorScheme.primary,
                          onSelected: (selected) {
                            setState(() {
                              selectedTimeFilter = label;
                            });
                          },
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
                          labelStyle: TextStyle(
                            color: label == selectedTimeFilter
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ))
                  .toList(),
            ).animate().fadeIn(duration: 1000.ms).slideX(begin: 0.1),
            const SizedBox(height: 20),
            Expanded(
              child: BlocBuilder<AnalyticsBloc, AnalyticsState>(
                builder: (context, state) {
                  if (state is AnalyticsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is AnalyticsError) {
                    return Center(child: Text(state.message));
                  } else if (state is AnalyticsLoaded) {
                    return GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.4,
                      children: [
                        _buildStatCard(
                          context,
                          'In Stock',
                          state.stockCount.toString(),
                          FontAwesomeIcons.accusoft,
                          theme.colorScheme.primary,
                        ),
                        _buildStatCard(
                          context,
                          'Orders',
                          ' state.ordersCount.toString(),',
                          Icons.reviews,
                          theme.colorScheme.secondary,
                          percentage: '13%',
                          isIncrease: true,
                        ),
                        _buildStatCard(
                          context,
                          'Feedback',
                          ' state.feedbackCount.toString(),',
                          Icons.thumb_up,
                          theme.colorScheme.tertiary,
                          percentage: '13%',
                          isIncrease: false,
                        ),
                        _buildStatCard(
                          context,
                          'Sales',
                          '2.6k',
                          FontAwesomeIcons.dollarSign,
                          theme.colorScheme.error,
                          percentage: '1.2%',
                          isIncrease: true,
                          extraInfo: '233 ASINs',
                        ),
                      ],
                    );
                  } else {
                    return const Center(child: Text('No data available.'));
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
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
                    "You don't have any Workflows running. Create a Workflow in order to view its insights here.",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(
                    height: 70,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Image.asset('assets/send.png')],
                    ),
                  ),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Center(child: Text('Feature coming soon..😎')),
                          ),
                        );
                      },
                      child: const Text('Create a Workflow'),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 1000.ms).slideX(begin: 0.1),
            const SizedBox(height: 20),
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

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                StatCardDetailView(
              title: title,
              value: value,
              icon: icon,
              color: color,
              percentage: percentage,
              isIncrease: isIncrease,
              extraInfo: extraInfo,
            ),
            transitionDuration: const Duration(milliseconds: 300),
            reverseTransitionDuration: const Duration(milliseconds: 300),
          ),
        );
      },
      child: Hero(
        tag: 'stat_card_$title',
        child: Material(
          color: Colors.transparent,
          child: Container(
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
          ),
        ),
      ),
    );
  }
}

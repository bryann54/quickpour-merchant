import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickpourmerchant/core/utils/colors.dart';
import 'package:quickpourmerchant/core/utils/custom_appbar.dart';
import 'package:quickpourmerchant/features/categories/presentation/bloc/categories_bloc.dart';
import 'package:quickpourmerchant/features/categories/presentation/bloc/categories_state.dart';
import 'package:quickpourmerchant/features/categories/presentation/pages/categories_screen.dart';
import 'package:quickpourmerchant/features/categories/presentation/widgets/horizontal_list_widget.dart';
import 'package:quickpourmerchant/features/categories/presentation/widgets/shimmer_widget.dart';
import 'package:quickpourmerchant/features/product/presentation/widgets/custom_fab_widget.dart';

class HomeScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        scaffoldKey: _scaffoldKey,
        title: const GradientText(text: 'QuickPour Merchant'),
      ),
      drawer: CustomDrawer(
        merchantName: 'QuickPour Merchant',
        onLogout: () {
          Navigator.pushReplacementNamed(context, '/login');
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 3, top: 2, bottom: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Categories',
                      style: GoogleFonts.montaga(
                        textStyle: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CategoriesScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'See All',
                      style: GoogleFonts.montaga(
                        textStyle:
                            Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: isDarkMode
                                      ? Colors.teal
                                      : AppColors.accentColor,
                                ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            BlocBuilder<CategoriesBloc, CategoriesState>(
              builder: (context, state) {
                if (state is CategoriesLoaded) {
                  return HorizontalCategoriesListWidget(
                    categories: state.categories,
                  );
                }
                return const Center(child: LoadingHorizontalList());
              },
            ),
            Row(
              children: [
                Text(
                  'Best Selling',
                  style: GoogleFonts.montaga(
                    textStyle: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: CustomFAB(),
    );
  }
}

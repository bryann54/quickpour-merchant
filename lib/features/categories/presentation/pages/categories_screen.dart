
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickpourmerchant/features/categories/presentation/widgets/shimmer_widget.dart';
import '../bloc/categories_bloc.dart';
import '../bloc/categories_state.dart';
import '../widgets/category_card.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
              title: Text(
                    ' Available Categories',
                    style: Theme.of(context).textTheme.displayLarge,
      )),
      body: BlocBuilder<CategoriesBloc, CategoriesState>(
        builder: (context, state) {
          if (state is CategoriesLoading) {
            return ListView.builder(
              itemCount: 6,
              itemBuilder: (context, index) => const LoadingHorizontalList(),
            );
          } else if (state is CategoriesLoaded) {
            return Column(
              children: [
            
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 5.0,
                      mainAxisSpacing: 5.0,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: state.categories.length,
                    itemBuilder: (context, index) {
                      final category = state.categories[index];
                      return CategoryCard(category: category);
                    },
                  ),
                ),
              ],
            );
          } else if (state is CategoriesError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('No categories available.'));
        },
      ),
    );
  }
}

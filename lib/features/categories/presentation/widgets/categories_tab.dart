import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickpourmerchant/features/categories/presentation/bloc/categories_bloc.dart';
import 'package:quickpourmerchant/features/categories/presentation/bloc/categories_state.dart';
import 'package:quickpourmerchant/features/categories/presentation/widgets/category_card.dart';
import 'package:quickpourmerchant/features/categories/presentation/widgets/shimmer_widget.dart';

class CategoriesTab extends StatelessWidget {
  const CategoriesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoriesBloc, CategoriesState>(
      builder: (context, state) {
        if (state is CategoriesLoading) {
          return ListView.builder(
            itemCount: 6,
            itemBuilder: (context, index) => const LoadingHorizontalList(),
          );
        } else if (state is CategoriesLoaded) {
          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 5.0,
              mainAxisSpacing: 5.0,
              childAspectRatio: 1.2,
            ),
            itemCount: state.allCategories.length,
            itemBuilder: (context, index) {
              final category = state.allCategories[index];
              return CategoryCard(category: category);
            },
          );
        } else if (state is CategoriesError) {
          return Center(child: Text(state.message));
        }
        return const Center(child: Text('No categories available.'));
      },
    );
  }
}

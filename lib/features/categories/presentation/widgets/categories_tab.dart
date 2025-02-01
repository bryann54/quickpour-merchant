import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickpourmerchant/features/categories/presentation/bloc/categories_bloc.dart';
import 'package:quickpourmerchant/features/categories/presentation/bloc/categories_state.dart';
import 'package:quickpourmerchant/features/categories/presentation/widgets/category_card.dart';
import 'package:quickpourmerchant/features/categories/presentation/widgets/search_bar.dart';
import 'package:quickpourmerchant/features/categories/presentation/widgets/shimmer_widget.dart';

class CategoriesTab extends StatefulWidget {
  const CategoriesTab({super.key});

  @override
  State<CategoriesTab> createState() => _CategoriesTabState();
}

class _CategoriesTabState extends State<CategoriesTab> {
  late TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query.toLowerCase().trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CustomSearchBar(
            controller: _searchController,
            onSearch: _onSearch,
            onFilterTap: () {}, 
          ),
        ),
        Expanded(
          child: BlocBuilder<CategoriesBloc, CategoriesState>(
            builder: (context, state) {
              if (state is CategoriesLoading) {
                return ListView.builder(
                  itemCount: 6,
                  itemBuilder: (context, index) =>
                      const LoadingHorizontalList(),
                );
              } else if (state is CategoriesLoaded) {
                // Filter categories based on search query
                final filteredCategories = state.allCategories
                    .where((category) =>
                        category.name.toLowerCase().contains(_searchQuery))
                    .toList();

                if (filteredCategories.isEmpty) {
                  return const Center(
                    child: Text("No category found matching your search."),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 5.0,
                    mainAxisSpacing: 5.0,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: filteredCategories.length,
                  itemBuilder: (context, index) {
                    final category = filteredCategories[index];
                    return CategoryCard(category: category);
                  },
                );
              } else if (state is CategoriesError) {
                return Center(child: Text(state.message));
              }
              return const Center(child: Text('No categories available.'));
            },
          ),
        ),
      ],
    );
  }
}

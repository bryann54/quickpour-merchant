import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickpourmerchant/features/brands/presentation/bloc/brands_bloc.dart';
import 'package:quickpourmerchant/features/brands/presentation/widgets/add_brand_dialog.dart';
import 'package:quickpourmerchant/features/brands/presentation/widgets/brands_card_widget.dart';
import 'package:quickpourmerchant/features/categories/presentation/widgets/search_bar.dart';
import 'package:quickpourmerchant/features/categories/presentation/widgets/shimmer_widget.dart';

class BrandsTab extends StatefulWidget {
  const BrandsTab({super.key});

  @override
  State<BrandsTab> createState() => _BrandsTabState();
}

class _BrandsTabState extends State<BrandsTab> {
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
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomSearchBar(
              controller: _searchController,
              onSearch: _onSearch,
              onFilterTap: () {}, // You can implement this later
            ),
          ),
          Expanded(
            child: BlocBuilder<BrandsBloc, BrandsState>(
              builder: (context, state) {
                if (state is BrandsLoadingState) {
                  return ListView.builder(
                    itemCount: 6,
                    itemBuilder: (context, index) =>
                        const LoadingHorizontalList(),
                  );
                } else if (state is BrandsLoadedState) {
                  final brands = state.brands
                      .where((brand) =>
                          brand.name.toLowerCase().contains(_searchQuery))
                      .toList();

                  if (brands.isEmpty) {
                    return const Center(
                      child: Text("No brands found matching your search."),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 5.0,
                      mainAxisSpacing: 5.0,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: brands.length,
                    itemBuilder: (context, index) {
                      final brand = brands[index];
                      return BrandCardWidget(brand: brand);
                    },
                  );
                } else if (state is BrandsErrorState) {
                  return Center(child: Text(state.errorMessage));
                }
                return const Center(child: Text('No brands available.'));
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => const AddBrandDialog(),
        ),
        label: const Text('Add New Brand'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

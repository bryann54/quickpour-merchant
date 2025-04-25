import 'dart:async';
import 'package:quickpourmerchant/core/utils/colors.dart';
import 'package:quickpourmerchant/features/auth/data/repositories/auth_repository.dart';
import 'package:quickpourmerchant/features/product/presentation/bloc/products_bloc.dart';
import 'package:quickpourmerchant/features/product/presentation/widgets/product_card.dart';
import 'package:quickpourmerchant/features/product_search/presentation/widgets/filter_bottomSheet.dart';
import 'package:quickpourmerchant/features/product/presentation/bloc/products_bloc.dart'
    as product_bloc;
import 'package:quickpourmerchant/features/product_search/presentation/bloc/product_search_event.dart';

import 'package:quickpourmerchant/features/product_search/presentation/widgets/product_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quickpourmerchant/features/requests/presentation/pages/requests_screen.dart';
import 'package:rxdart/rxdart.dart';

import 'package:quickpourmerchant/features/product/data/repositories/product_repository.dart';
import 'package:quickpourmerchant/features/product_search/presentation/bloc/product_search_bloc.dart';
import 'package:quickpourmerchant/features/product_search/presentation/bloc/product_search_state.dart';

class SearchPage extends StatefulWidget {
  final AuthRepository authRepository;
  final TextEditingController? searchController;

  const SearchPage({
    super.key,
    this.searchController,
    required this.authRepository,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late ScrollController _scrollController;
  late ProductSearchBloc _productSearchBloc;
  late TextEditingController _searchController;
  final _searchSubject = PublishSubject<String>();
  StreamSubscription? _searchSubscription;
  bool _isFirstSearch = true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupSearchStream();
    _triggerInitialSearch();
  }

  void _initializeControllers() {
    _scrollController = ScrollController();
    _productSearchBloc = ProductSearchBloc(
      productRepository: ProductRepository(),
    );
    _searchController = widget.searchController ?? TextEditingController();
  }

  void _setupSearchStream() {
    _searchController.addListener(_onSearchTextChanged);

    _searchSubscription = _searchSubject
        .debounceTime(const Duration(milliseconds: 500))
        .distinct()
        .listen(_onSearchQuery);
  }

  void _onSearchTextChanged() {
    if (mounted) {
      _searchSubject.add(_searchController.text);
    }
  }

  void _onSearchQuery(String query) {
    if (mounted) {
      debugPrint('Searching for: $query'); // Debug log
      _productSearchBloc.add(SearchProductsEvent(query));
    }
  }

  void _triggerInitialSearch() {
    if (_searchController.text.isNotEmpty) {
      // Small delay to ensure everything is properly initialized
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && _isFirstSearch) {
          _isFirstSearch = false;
          _searchSubject.add(_searchController.text);
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchSubscription?.cancel();
    _searchSubject.close();
    _productSearchBloc.close();

    if (widget.searchController == null) {
      _searchController.dispose();
    }

    super.dispose();
  }

  void _openFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => FilterBottomSheet(
          onApplyFilters: (filters) {
            _productSearchBloc.add(
              product_bloc.FilterProductsEvent(
                category: filters['category'] as String?,
                store: filters['store'] as String?,
                priceRange: filters['priceRange'] as RangeValues?,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _productSearchBloc),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isDarkMode
                    ? AppColors.accentColor.withOpacity(.3)
                    : Colors.grey.shade300,
              ),
              color: isDarkMode ? Colors.grey.shade600 : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'Search product',
                hintStyle: Theme.of(context).textTheme.bodyMedium,
                border: InputBorder.none,
                suffixIcon: IconButton(
                  icon: const FaIcon(Icons.tune),
                  onPressed: _openFilterBottomSheet,
                ),
              ),
            ),
          ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.1),
        ),
        body: BlocBuilder<ProductSearchBloc, ProductSearchState>(
          builder: (context, searchState) {
            if (searchState is ProductSearchLoadingState) {
              return const Center(
                child: CircularProgressIndicator.adaptive(),
              );
            }

            if (searchState is ProductSearchLoadedState) {
              if (searchState.searchResults.isNotEmpty) {
                return GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: searchState.searchResults.length,
                  itemBuilder: (context, index) {
                    final product = searchState.searchResults[index];
                    return ProductCard(product: product);
                  },
                );
              } else {
                return _buildNoResultsFound();
              }
            }

            return _buildProductList();
          },
        ),
      ),
    );
  }

  Widget _buildNoResultsFound() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Oops!!... didn\'t find "${_searchController.text}"'),
          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RequestsScreen(),
                  ),
                );
              },
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: isDarkMode
                      ? AppColors.background.withOpacity(.8)
                      : AppColors.backgroundDark,
                ),
                child: Center(
                  child: Text(
                    'make drink request',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isDarkMode
                          ? AppColors.backgroundDark
                          : AppColors.background,
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildProductList() {
    return BlocProvider<ProductsBloc>(
      create: (context) => ProductsBloc(
        productRepository: ProductRepository(),
      )..add(FetchMerchantProducts(
          widget.authRepository.getCurrentUserId()!,
        )),
      child: const ProductListWidget(),
    );
  }
}

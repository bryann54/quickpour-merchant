part of 'products_bloc.dart';

abstract class ProductsState extends Equatable {
  const ProductsState();

  @override
  List<Object> get props => [];
}

class ProductsInitial extends ProductsState {}

class ProductsLoading extends ProductsState {}

class ProductsLoaded extends ProductsState {
  final List<MerchantProductModel> products;
  final bool hasMoreData;
  final DateTime lastFetched;

  const ProductsLoaded({
    required this.products,
    required this.lastFetched,
    this.hasMoreData = true,
  });

  @override
  List<Object> get props => [products];
}

class ProductsError extends ProductsState {
  final String message;

  const ProductsError(this.message);

  @override
  List<Object> get props => [message];
}

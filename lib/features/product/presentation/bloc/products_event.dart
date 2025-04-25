part of 'products_bloc.dart';

abstract class ProductsEvent extends Equatable {
  const ProductsEvent();

  @override
  List<Object> get props => [];
}

class ProductErrorEvent extends ProductsEvent {
  final String error;

  const ProductErrorEvent(this.error);

  @override
  List<Object> get props => [error];
}

class FetchProducts extends ProductsEvent {}

class UpdateProductsList extends ProductsEvent {
  final List<MerchantProductModel> products;

  const UpdateProductsList(this.products);

  @override
  List<Object> get props => [products];
}

class AddProduct extends ProductsEvent {
  final MerchantProductModel product;

  const AddProduct(this.product);

  @override
  List<Object> get props => [product];
}

class UpdateProduct extends ProductsEvent {
  final MerchantProductModel product;

  const UpdateProduct(this.product);

  @override
  List<Object> get props => [product];
}

class DeleteProduct extends ProductsEvent {
  final String productId;

  const DeleteProduct(this.productId);

  @override
  List<Object> get props => [productId];
}

class LoadMoreProductsEvent extends ProductsEvent {}

//  new event to fetch merchant specific products
class FetchMerchantProducts extends ProductsEvent {
  final String merchantId;

  const FetchMerchantProducts(this.merchantId);

  @override
  List<Object> get props => [merchantId];
}

class FilterProductsEvent extends ProductSearchEvent {
  final String? category;
  final String? store;
  final String? brand;
  final RangeValues? priceRange;

  const FilterProductsEvent({
    this.category,
    this.store,
    this.brand,
    this.priceRange,
  });

  @override
  List<Object> get props => [
        category ?? '', // Provide a default empty string for null
        store ?? '',
        brand ?? '', // Provide a default empty string for null
        priceRange ??
            const RangeValues(
                0, 10000), // Provide a default RangeValues for null
      ];
}

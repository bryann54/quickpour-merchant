part of 'products_bloc.dart';

abstract class ProductsEvent extends Equatable {
  const ProductsEvent();

  @override
  List<Object> get props => [];
}

class FetchProducts extends ProductsEvent {}

class UpdateProductsList extends ProductsEvent {
  final List<ProductModel> products;

  const UpdateProductsList(this.products);

  @override
  List<Object> get props => [products];
}

class AddProduct extends ProductsEvent {
  final ProductModel product;

  const AddProduct(this.product);

  @override
  List<Object> get props => [product];
}

class UpdateProduct extends ProductsEvent {
  final ProductModel product;

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

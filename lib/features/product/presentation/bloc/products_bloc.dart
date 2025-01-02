import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:quickpourmerchant/features/product/data/models/product_model.dart';
import 'package:quickpourmerchant/features/product/data/repositories/product_repository.dart';

part 'products_event.dart';
part 'products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final ProductRepository productRepository;
  StreamSubscription<QuerySnapshot>? _productsSubscription;

  ProductsBloc({required this.productRepository}) : super(ProductsInitial()) {
    on<FetchProducts>((event, emit) async {
      emit(ProductsLoading());
      try {
        // Set up real-time stream
        _productsSubscription?.cancel();
        _productsSubscription = FirebaseFirestore.instance
            .collection('products')
            .snapshots()
            .listen((snapshot) {
          final products = snapshot.docs
              .map((doc) =>
                  ProductModel.fromMap(doc.data()))
              .toList();
          add(UpdateProductsList(products));
        });
      } catch (e) {
        emit(ProductsError('Failed to fetch products: ${e.toString()}'));
      }
    });

    on<UpdateProductsList>((event, emit) {
      emit(ProductsLoaded(event.products));
    });

    on<AddProduct>((event, emit) async {
      try {
        await productRepository.addProduct(event.product);
      } catch (e) {
        emit(ProductsError('Failed to add product: ${e.toString()}'));
      }
    });

    on<UpdateProduct>((event, emit) async {
      try {
        await productRepository.updateProduct(event.product);
      } catch (e) {
        emit(ProductsError('Failed to update product: ${e.toString()}'));
      }
    });

    on<DeleteProduct>((event, emit) async {
      try {
        await productRepository.deleteProduct(event.productId);
      } catch (e) {
        emit(ProductsError('Failed to delete product:  ${e.toString()}'));
      }
    });
  }

  @override
  Future<void> close() {
    _productsSubscription?.cancel();
    return super.close();
  }
}

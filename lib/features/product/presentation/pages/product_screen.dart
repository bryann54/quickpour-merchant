import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickpourmerchant/features/product/presentation/bloc/products_bloc.dart';

class ProductsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Products')),
      body: BlocBuilder<ProductsBloc, ProductsState>(
        builder: (context, state) {
          if (state is ProductsLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is ProductsLoaded) {
            return ListView.builder(
              itemCount: state.products.length,
              itemBuilder: (context, index) {
                final product = state.products[index];
                return ListTile(
                  title: Text(product.productName),
                  subtitle: Text('\$${product.price}'),
                );
              },
            );
          } else if (state is ProductsError) {
            return Center(child: Text(state.message));
          }
          return Center(child: Text('No Products'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Trigger AddProduct or other events
          // Example: AddProduct(ProductModel(...))
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

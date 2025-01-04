import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickpourmerchant/features/categories/domain/entities/category.dart';
import 'package:quickpourmerchant/features/categories/presentation/bloc/categories_bloc.dart';
import 'package:quickpourmerchant/features/categories/presentation/bloc/categories_state.dart';
import 'package:quickpourmerchant/features/product/data/models/product_model.dart';
import 'package:quickpourmerchant/features/product/presentation/bloc/products_bloc.dart';

class AddProductDialog extends StatefulWidget {
  const AddProductDialog({super.key});

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
   final _auth = FirebaseAuth.instance; 
  String? _selectedCategory;
  String? _productName;
  double? _price;
  double? _discountPrice;
  int? _stockQuantity;
  String? _sku;
  String? _description;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add Product',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              BlocBuilder<CategoriesBloc, CategoriesState>(
                builder: (context, state) {
                  if (state is CategoriesLoading) {
                    return const CircularProgressIndicator.adaptive();
                  } else if (state is CategoriesLoaded) {
                    return DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      items: state.categories
                          .map((Category category) => DropdownMenuItem<String>(
                                value: category.id,
                                child: Text(category.name),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Select Category',
                      ),
                      validator: (value) =>
                          value == null ? 'Please select a category' : null,
                    );
                  } else if (state is CategoriesError) {
                    return Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Product Name'),
                onChanged: (value) => _productName = value,
                validator: (value) =>
                    value!.isEmpty ? 'Enter product name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                onChanged: (value) => _price = double.tryParse(value),
                validator: (value) =>
                    value!.isEmpty ? 'Enter product price' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Discount Price'),
                keyboardType: TextInputType.number,
                onChanged: (value) => _discountPrice = double.tryParse(value),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Stock Quantity'),
                keyboardType: TextInputType.number,
                onChanged: (value) => _stockQuantity = int.tryParse(value),
                validator: (value) =>
                    value!.isEmpty ? 'Enter stock quantity' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'SKU'),
                onChanged: (value) => _sku = value,
                validator: (value) => value!.isEmpty ? 'Enter SKU' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (value) => _description = value,
                validator: (value) =>
                    value!.isEmpty ? 'Enter description' : null,
              ),
              const SizedBox(height: 16),
        ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      final User? user = _auth.currentUser;

                      if (user == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please log in to add products'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      final String productId = FirebaseFirestore.instance
                          .collection('products')
                          .doc()
                          .id;

                      final newProduct = ProductModel(
                        id: productId,
                        merchantId: user.uid,
                        productName: _productName!,
                        imageUrls: [],
                        price: _price!,
                        brand: '',
                        description: _description!,
                        category: _selectedCategory!,
                        stockQuantity: _stockQuantity!,
                        discountPrice: _discountPrice ?? 0.0,
                        sku: _sku!,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      );

                      context.read<ProductsBloc>().add(AddProduct(newProduct));
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Product added successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error adding product: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Add Product'),
              ), ],
          ),
        ),
      ),
    );
  }
}

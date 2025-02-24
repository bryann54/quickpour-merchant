import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickpourmerchant/features/auth/data/repositories/auth_repository.dart';
import 'package:quickpourmerchant/features/brands/presentation/bloc/brands_bloc.dart';
import 'package:quickpourmerchant/features/categories/presentation/bloc/categories_bloc.dart';
import 'package:quickpourmerchant/features/categories/presentation/bloc/categories_state.dart';
import 'package:quickpourmerchant/features/product/data/models/product_model.dart';
import 'package:quickpourmerchant/features/product/presentation/bloc/products_bloc.dart';
import 'package:quickpourmerchant/features/product/presentation/widgets/measure_input.dart';

class AddProductDialog extends StatefulWidget {
  const AddProductDialog({super.key});

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _authRepository = AuthRepository();
  bool _isLoading = false;

  // Controllers for form fields
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();
  final _stockController = TextEditingController();
  final _skuController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _measureController = TextEditingController();

  String? _selectedCategory;
  String? _selectedBrand;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _stockController.dispose();
    _skuController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Validation helpers
  String? _validatePrice(String? value) {
    if (value == null || value.isEmpty) return 'Price is required';
    if (double.tryParse(value) == null) return 'Enter a valid price';
    if (double.parse(value) <= 0) return 'Price must be greater than 0';
    return null;
  }

  String? _validateStock(String? value) {
    if (value == null || value.isEmpty) return 'Stock quantity is required';
    if (int.tryParse(value) == null) return 'Enter a valid number';
    if (int.parse(value) < 0) return 'Stock cannot be negative';
    return null;
  }

  String? _validateDiscount(String? value) {
    if (value == null || value.isEmpty) return null;
    if (double.tryParse(value) == null) return 'Enter a valid price';
    if (double.parse(value) < 0) return 'Discount cannot be negative';
    if (double.parse(value) >= double.parse(_priceController.text)) {
      return 'Discount must be less than price';
    }
    return null;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = _auth.currentUser;
      if (user == null) {
        _showErrorMessage('Please log in to add products');
        return;
      }
      final merchantDetails = await _authRepository.getCurrentUserDetails();
      if (merchantDetails == null) {
        _showErrorMessage('Could not fetch merchant details');
        return;
      }

      final productId =
          FirebaseFirestore.instance.collection('products').doc().id;
      final newProduct = MerchantProductModel(
        id: productId,
        merchantId: user.uid,
        measure: _measureController.text,
        productName: _nameController.text.trim(),
        imageUrls: const [], // Empty as this is version without images
        price: double.parse(_priceController.text),
        brandName: _selectedBrand!,
        description: _descriptionController.text.trim(),
        categoryName: _selectedCategory!,
        stockQuantity: int.parse(_stockController.text),
        discountPrice: _discountController.text.isEmpty
            ? 0.0
            : double.parse(_discountController.text),
        sku: _skuController.text.trim(),
        merchantName: merchantDetails.name,
        merchantEmail: merchantDetails.email,
        merchantLocation: merchantDetails.location,
        merchantStoreName: merchantDetails.storeName,
        merchantImageUrl: merchantDetails.imageUrl,
        merchantRating: merchantDetails.rating,
        isMerchantVerified: merchantDetails.isVerified,
        isMerchantOpen: merchantDetails.isOpen,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      context.read<ProductsBloc>().add(AddProduct(newProduct));
      Navigator.pop(context);
      _showSuccessMessage('Product added successfully');
    } catch (e) {
      _showErrorMessage('Error adding product: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: SingleChildScrollView(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        'Add New Product',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.cancel),
                      tooltip: 'Cancel',
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Category Dropdown
                BlocBuilder<CategoriesBloc, CategoriesState>(
                  builder: (context, state) {
                    if (state is CategoriesLoading) {
                      return const LinearProgressIndicator();
                    } else if (state is CategoriesLoaded) {
                      return DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.category),
                        ),
                        items: state.allCategories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category.name,
                            child: Text(category.name),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => _selectedCategory = value),
                        validator: (value) =>
                            value == null ? 'Select a category' : null,
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 16),

                // Brand Dropdown
                BlocBuilder<BrandsBloc, BrandsState>(
                  builder: (context, state) {
                    if (state is BrandsLoadingState) {
                      return const LinearProgressIndicator();
                    } else if (state is BrandsLoadedState) {
                      return DropdownButtonFormField<String>(
                        value: _selectedBrand,
                        decoration: InputDecoration(
                          labelText: 'Brand',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.branding_watermark),
                        ),
                        items: state.brands.map((brand) {
                          return DropdownMenuItem<String>(
                            value: brand.name,
                            child: Text(brand.name),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => _selectedBrand = value),
                        validator: (value) =>
                            value == null ? 'Select a brand' : null,
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 16),

                // Product Details
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Product Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.inventory),
                  ),
                  validator: (value) => value?.trim().isEmpty == true
                      ? 'Enter product name'
                      : null,
                ),
                const SizedBox(height: 16),
                MeasureInputField(
                  controller: _measureController,
                ),
                const SizedBox(height: 16),
                // Price and Discount Row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        decoration: InputDecoration(
                          labelText: 'Price',
                          prefixText: 'Ksh ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.attach_money),
                        ),
                        keyboardType: TextInputType.number,
                        validator: _validatePrice,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _discountController,
                        decoration: InputDecoration(
                          labelText: 'Discount Price',
                          prefixText: 'Ksh ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.discount),
                        ),
                        keyboardType: TextInputType.number,
                        validator: _validateDiscount,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Stock and SKU Row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _stockController,
                        decoration: InputDecoration(
                          labelText: 'Stock Quantity',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.warehouse),
                        ),
                        keyboardType: TextInputType.number,
                        validator: _validateStock,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _skuController,
                        decoration: InputDecoration(
                          labelText: 'SKU',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.qr_code),
                        ),
                        validator: (value) =>
                            value?.trim().isEmpty == true ? 'Enter SKU' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.description),
                  ),
                  maxLines: 3,
                  validator: (value) => value?.trim().isEmpty == true
                      ? 'Enter description'
                      : null,
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Add Product'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

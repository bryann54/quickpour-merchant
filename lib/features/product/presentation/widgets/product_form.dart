import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickpourmerchant/core/utils/strings.dart';
import 'package:quickpourmerchant/features/brands/data/models/brands_model.dart';
import 'package:quickpourmerchant/features/product/data/models/product_model.dart';
import 'package:quickpourmerchant/features/product/presentation/bloc/products_bloc.dart';
import 'package:quickpourmerchant/features/product/presentation/widgets/custom_text_field.dart';
import 'package:quickpourmerchant/features/product/presentation/widgets/product_info.dart';
import 'package:quickpourmerchant/features/product/presentation/widgets/product_tags.dart';
import 'package:quickpourmerchant/features/categories/domain/entities/category.dart';
import 'package:quickpourmerchant/features/categories/presentation/bloc/categories_bloc.dart';
import 'package:quickpourmerchant/features/categories/presentation/bloc/categories_state.dart';
import 'package:quickpourmerchant/features/brands/presentation/bloc/brands_bloc.dart';

class ProductForm extends StatefulWidget {
  final MerchantProductModel product;
  final bool isEditing;
  final VoidCallback onUpdateComplete;

  const ProductForm({
    Key? key,
    required this.product,
    required this.isEditing,
    required this.onUpdateComplete,
  }) : super(key: key);

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _auth = FirebaseAuth.instance;
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _discountPriceController;
  late final TextEditingController _stockController;
  late final TextEditingController _skuController;
  final _measureController = TextEditingController();
  String? _selectedCategory;
  String? _selectedBrand;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(
      text: widget.product.productName,
    );
    _descriptionController =
        TextEditingController(text: widget.product.description);
    _priceController =
        TextEditingController(text: widget.product.price.toString());
    _discountPriceController = TextEditingController(
        text: widget.product.discountPrice > 0
            ? widget.product.discountPrice.toString()
            : '');
    _stockController =
        TextEditingController(text: widget.product.stockQuantity.toString());
    _skuController = TextEditingController(text: widget.product.sku);
    _selectedCategory = widget.product.categoryName;
    _selectedBrand = widget.product.brandName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _discountPriceController.dispose();
    _stockController.dispose();
    _skuController.dispose();
    super.dispose();
  }

  Future<void> _updateProduct() async {
    if (!_validateInputs()) return;

    try {
      final User? user = _auth.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in to update products'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final updatedProduct = MerchantProductModel(
        merchantId: user.uid,
        id: widget.product.id,
        measure: _measureController.text.trim(),
        productName: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.tryParse(_priceController.text.trim()) ?? 0.0,
        discountPrice:
            double.tryParse(_discountPriceController.text.trim()) ?? 0.0,
        stockQuantity: int.tryParse(_stockController.text.trim()) ?? 0,
        brandName: _selectedBrand ?? widget.product.brandName,
        categoryName: _selectedCategory ?? widget.product.categoryName,
        sku: _skuController.text.trim(),
        imageUrls: widget.product.imageUrls,
        tags: widget.product.tags,
        createdAt: widget.product.createdAt,
        updatedAt: DateTime.now(),
        merchantName: user.displayName ?? '',
        merchantEmail: user.email ?? '',
        merchantLocation: widget.product.merchantLocation,
        merchantStoreName: widget.product.merchantStoreName,
        merchantImageUrl: widget.product.merchantImageUrl,
        merchantRating: widget.product.merchantRating,
        isMerchantVerified: widget.product.isMerchantVerified,
        isMerchantOpen: widget.product.isMerchantOpen,
      );

      if (widget.product.merchantId != user.uid) {
        throw Exception('Unauthorized to update this product');
      }

      context.read<ProductsBloc>().add(UpdateProduct(updatedProduct));
      widget.onUpdateComplete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error updating product'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool _validateInputs() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product name cannot be empty')),
      );
      return false;
    }

    if (_selectedCategory == null || _selectedCategory!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return false;
    }

    if (_selectedBrand == null || _selectedBrand!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a brand')),
      );
      return false;
    }

    try {
      final price = double.tryParse(_priceController.text);
      final stock = int.tryParse(_stockController.text);
      final discountPrice = _discountPriceController.text.isNotEmpty
          ? double.tryParse(_discountPriceController.text)
          : 0.0;

      if (price == null || price < 0) {
        throw Exception('Invalid price');
      }
      if (stock == null || stock < 0) {
        throw Exception('Invalid stock');
      }
      if (discountPrice != null && discountPrice > price) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Discount price cannot be greater than regular price')),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(valid_stock_txt)),
      );
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'product_name_${widget.product.id}',
              child: Material(
                child: CustomTextField(
                  label: 'Product Name',
                  controller: _nameController,
                  enabled: widget.isEditing,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildPriceFields(),
            const SizedBox(height: 16),
            _buildStockField(),
            const SizedBox(height: 16),
            _buildCategoryAndBrandFields(),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Description',
              controller: _descriptionController,
              enabled: widget.isEditing,
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            ProductTags(tags: widget.product.tags),
            const SizedBox(height: 16),
            _buildProductInfo(),
            if (widget.isEditing) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _updateProduct,
                      child: const Text('Update Product'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPriceFields() {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            label: 'Price (Ksh)',
            controller: _priceController,
            enabled: widget.isEditing,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CustomTextField(
            label: 'Discount Price (Optional)',
            controller: _discountPriceController,
            enabled: widget.isEditing,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            // hintText: 'Enter discount price',
          ),
        ),
      ],
    );
  }

  Widget _buildStockField() {
    return CustomTextField(
      label: 'Stock',
      controller: _stockController,
      enabled: widget.isEditing,
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildCategoryAndBrandFields() {
    return Row(
      children: [
        Expanded(
          child: BlocBuilder<BrandsBloc, BrandsState>(
            builder: (context, state) {
              if (state is BrandsLoadingState) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is BrandsLoadedState) {
                final brands = state.brands;
                return DropdownButtonFormField<String>(
                  value: _selectedBrand,
                  decoration: const InputDecoration(
                    labelText: 'Brand',
                    border: OutlineInputBorder(),
                  ),
                  items: brands.map((BrandModel brand) {
                    return DropdownMenuItem<String>(
                      value: brand.name,
                      child: Text(brand.name),
                    );
                  }).toList(),
                  onChanged: widget.isEditing
                      ? (String? value) {
                          setState(() {
                            _selectedBrand = value;
                          });
                        }
                      : null,
                );
              } else if (state is BrandsErrorState) {
                return Text('Error: ${state.errorMessage}',
                    style: const TextStyle(color: Colors.red));
              }
              return CustomTextField(
                label: 'Brand',
                controller:
                    TextEditingController(text: widget.product.brandName),
                enabled: false,
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: BlocBuilder<CategoriesBloc, CategoriesState>(
            builder: (context, state) {
              if (state is CategoriesLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is CategoriesLoaded) {
                final categories = state.allCategories;
                return DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: categories.map((Category category) {
                    return DropdownMenuItem<String>(
                      value: category.name,
                      child: Text(category.name),
                    );
                  }).toList(),
                  onChanged: widget.isEditing
                      ? (String? value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        }
                      : null,
                );
              } else if (state is CategoriesError) {
                return Text('Error: ${state.message}',
                    style: const TextStyle(color: Colors.red));
              }
              return CustomTextField(
                label: 'Category',
                controller:
                    TextEditingController(text: widget.product.categoryName),
                enabled: false,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SKU: ${widget.product.sku}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        ProductInfo(
          product: widget.product,
        )
      ],
    );
  }
}

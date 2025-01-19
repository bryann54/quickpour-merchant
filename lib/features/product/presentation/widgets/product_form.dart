import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickpourmerchant/core/utils/strings.dart';
import 'package:quickpourmerchant/features/product/data/models/product_model.dart';
import 'package:quickpourmerchant/features/product/presentation/bloc/products_bloc.dart';
import 'package:quickpourmerchant/features/product/presentation/widgets/custom_text_field.dart';
import 'package:quickpourmerchant/features/product/presentation/widgets/product_info.dart';
import 'package:quickpourmerchant/features/product/presentation/widgets/product_tags.dart';
import 'package:quickpourmerchant/features/categories/domain/entities/category.dart';
import 'package:quickpourmerchant/features/categories/presentation/bloc/categories_bloc.dart';
import 'package:quickpourmerchant/features/categories/presentation/bloc/categories_state.dart';

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
  late final TextEditingController _brandController;
  late final TextEditingController _skuController;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.product.productName);
    _descriptionController =
        TextEditingController(text: widget.product.description);
    _priceController =
        TextEditingController(text: widget.product.price.toString());
    _discountPriceController =
        TextEditingController(text: widget.product.discountPrice.toString());
    _stockController =
        TextEditingController(text: widget.product.stockQuantity.toString());
    _brandController = TextEditingController(text: widget.product.brandName);
    _skuController = TextEditingController(text: widget.product.sku);
    _selectedCategory = widget.product.categoryName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _discountPriceController.dispose();
    _stockController.dispose();
    _brandController.dispose();
    _skuController.dispose();
    super.dispose();
  }

  Future<void> _updateProduct() async {
    if (!_validateInputs()) return;

    try {
      // Get current user
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
        productName: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.tryParse(_priceController.text) ?? 0.0,
        discountPrice: double.tryParse(_discountPriceController.text) ?? 0.0,
        stockQuantity: int.tryParse(_stockController.text) ?? 0,
        brandName: _brandController.text.trim(),
        categoryName: _selectedCategory ?? widget.product.categoryName,
        sku: _skuController.text.trim(),
        imageUrls: widget.product.imageUrls,
        tags: widget.product.tags,
        createdAt: widget.product.createdAt,
        updatedAt: DateTime.now(),
      );

      if (widget.product.merchantId != user.uid) {
        throw Exception('Unauthorized to update this product');
      }

      context.read<ProductsBloc>().add(UpdateProduct(updatedProduct));
      widget.onUpdateComplete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(product_update),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating product: ${error.toString()}'),
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

    try {
      final price = double.tryParse(_priceController.text);
      final stock = int.tryParse(_stockController.text);

      if (price == null || price < 0) {
        throw Exception('Invalid price');
      }
      if (stock == null || stock < 0) {
        throw Exception('Invalid stock');
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            label: 'Product Name',
            controller: _nameController,
            enabled: widget.isEditing,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildPriceAndStockFields(),
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
            ElevatedButton(
              onPressed: _updateProduct,
              child: const Text('Update Product'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPriceAndStockFields() {
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
        const Spacer(),
      ],
    );
  }

  Widget _buildCategoryAndBrandFields() {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            label: 'Brand',
            controller: _brandController,
            enabled: widget.isEditing,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: BlocBuilder<CategoriesBloc, CategoriesState>(
            builder: (context, state) {
              if (state is CategoriesLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is CategoriesLoaded) {
                final categories = state.categories;
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'SKU: ${widget.product.sku}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                label: 'Stock',
                controller: _stockController,
                enabled: widget.isEditing,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ProductInfo(
          product: widget.product,
        )
      ],
    );
  }
}

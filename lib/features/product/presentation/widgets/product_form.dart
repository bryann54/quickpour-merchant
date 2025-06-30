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
    _nameController = TextEditingController(text: widget.product.productName);
    _descriptionController =
        TextEditingController(text: widget.product.description);
    _priceController =
        TextEditingController(text: widget.product.price.toString());
    _discountPriceController = TextEditingController(
      text: widget.product.discountPrice > 0
          ? widget.product.discountPrice.toString()
          : '',
    );
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
            behavior: SnackBarBehavior.floating,
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
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating product: ${error.toString()}'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool _validateInputs() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product name cannot be empty'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }

    if (_selectedCategory == null || _selectedCategory!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }

    if (_selectedBrand == null || _selectedBrand!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a brand'),
          behavior: SnackBarBehavior.floating,
        ),
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
                Text('Discount price cannot be greater than regular price'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(valid_stock_txt),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product Name
        Hero(
          tag: 'product_name_${widget.product.id}',
          child: Material(
            type: MaterialType.transparency,
            child: CustomTextField(
              label: 'Product Name',
              controller: _nameController,
              enabled: widget.isEditing,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Pricing Section
        _buildPriceFields(),
        const SizedBox(height: 20),

        // Inventory Section
        _buildStockField(),
        const SizedBox(height: 20),

        // Classification Section
        _buildCategoryAndBrandFields(),
        const SizedBox(height: 20),

        // Description
        CustomTextField(
          label: 'Description',
          controller: _descriptionController,
          enabled: widget.isEditing,
          maxLines: 3,
        ),
        const SizedBox(height: 20),

        // Tags
        ProductTags(tags: widget.product.tags),
        const SizedBox(height: 20),

        // Product Information Card
        _buildProductInfoCard(),

        // Update Button
        if (widget.isEditing) ...[
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _updateProduct,
              child: const Text(
                'UPDATE PRODUCT',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildPriceFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pricing',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'Price (Ksh)',
                controller: _priceController,
                enabled: widget.isEditing,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                label: 'Discount Price (Optional)',
                controller: _discountPriceController,
                enabled: widget.isEditing,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStockField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Inventory',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        CustomTextField(
          label: 'Stock Quantity',
          controller: _stockController,
          enabled: widget.isEditing,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildCategoryAndBrandFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Classification',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: BlocBuilder<BrandsBloc, BrandsState>(
                builder: (context, state) {
                  if (state is BrandsLoadingState) {
                    return _buildDropdownLoading('Brand');
                  } else if (state is BrandsLoadedState) {
                    final brands = state.brands;
                    return DropdownButtonFormField<String>(
                      value: _selectedBrand,
                      decoration: InputDecoration(
                        labelText: 'Brand',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      items: brands.map((BrandModel brand) {
                        return DropdownMenuItem<String>(
                          value: brand.name,
                          child: Text(
                            brand.name,
                            style: const TextStyle(fontSize: 14),
                          ),
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
                  }
                  return _buildDropdownError('Brand');
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: BlocBuilder<CategoriesBloc, CategoriesState>(
                builder: (context, state) {
                  if (state is CategoriesLoading) {
                    return _buildDropdownLoading('Category');
                  } else if (state is CategoriesLoaded) {
                    final categories = state.allCategories;
                    return DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      items: categories.map((Category category) {
                        return DropdownMenuItem<String>(
                          value: category.name,
                          child: Text(
                            category.name,
                            style: const TextStyle(fontSize: 14),
                          ),
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
                  }
                  return _buildDropdownError('Category');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdownLoading(String label) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        suffixIcon: const Padding(
          padding: EdgeInsets.all(12),
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      enabled: false,
    );
  }

  Widget _buildDropdownError(String label) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      enabled: false,
    );
  }

  Widget _buildProductInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Product Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'SKU: ${widget.product.sku}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          ProductInfo(product: widget.product),
        ],
      ),
    );
  }
}

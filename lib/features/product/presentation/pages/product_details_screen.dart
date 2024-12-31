import 'package:flutter/material.dart';
import 'package:quickpourmerchant/features/product/data/models/product_model.dart';
import 'package:intl/intl.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsScreen({Key? key, required this.product})
      : super(key: key);

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _discountPriceController;
  late TextEditingController _stockController;
  late TextEditingController _brandController;
  late TextEditingController _categoryController;
  late TextEditingController _skuController;

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
    _brandController = TextEditingController(text: widget.product.brand);
    _categoryController = TextEditingController(text: widget.product.category);
    _skuController = TextEditingController(text: widget.product.sku);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _discountPriceController.dispose();
    _stockController.dispose();
    _brandController.dispose();
    _categoryController.dispose();
    _skuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Product' : 'Product Details'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              setState(() {
                if (_isEditing) {
                  // TODO: Implement save functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Changes saved successfully')),
                  );
                }
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Carousel
            SizedBox(
              height: 300,
              child: PageView.builder(
                itemCount: widget.product.imageUrls.isEmpty
                    ? 1
                    : widget.product.imageUrls.length,
                itemBuilder: (context, index) {
                  if (widget.product.imageUrls.isEmpty) {
                    return const Center(
                      child: Icon(Icons.image_not_supported, size: 100),
                    );
                  }
                  return Hero(
                    tag: 'productImage_${widget.product.id}_$index',
                    child: Image.network(
                      widget.product.imageUrls[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(child: Icon(Icons.error_outline)),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  _buildTextField(
                    label: 'Product Name',
                    controller: _nameController,
                    enabled: _isEditing,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Price and Discount Section
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'Price (Ksh)',
                          controller: _priceController,
                          enabled: _isEditing,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          label: 'Discount Price (Ksh)',
                          controller: _discountPriceController,
                          enabled: _isEditing,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Stock and SKU Section
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'Stock Quantity',
                          controller: _stockController,
                          enabled: _isEditing,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          label: 'SKU',
                          controller: _skuController,
                          enabled: _isEditing,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Brand and Category Section
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'Brand',
                          controller: _brandController,
                          enabled: _isEditing,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          label: 'Category',
                          controller: _categoryController,
                          enabled: _isEditing,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description
                  _buildTextField(
                    label: 'Description',
                    controller: _descriptionController,
                    enabled: _isEditing,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),

                  // Tags
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tags',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Wrap(
                            spacing: 8,
                            children: widget.product.tags
                                .map((tag) => Chip(
                                      label: Text(tag),
                                      deleteIcon: _isEditing
                                          ? const Icon(Icons.close, size: 16)
                                          : null,
                                      onDeleted: _isEditing ? () {} : null,
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Metadata
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Created: ${DateFormat('MMM dd, yyyy').format(widget.product.createdAt)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            'Last Updated: ${DateFormat('MMM dd, yyyy').format(widget.product.updatedAt)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool enabled = true,
    TextInputType? keyboardType,
    int? maxLines,
    TextStyle? style,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines ?? 1,
      style: style,
      decoration: InputDecoration(
        labelText: label,
        border: enabled ? const OutlineInputBorder() : InputBorder.none,
        filled: enabled,
        fillColor: enabled ? Colors.white : Colors.transparent,
      ),
    );
  }
}

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:quickpourmerchant/features/categories/domain/entities/category.dart';
import 'package:quickpourmerchant/features/categories/presentation/bloc/categories_bloc.dart';
import 'package:quickpourmerchant/features/categories/presentation/bloc/categories_state.dart';
import 'package:quickpourmerchant/features/product/data/models/product_model.dart';
import 'package:quickpourmerchant/features/product/presentation/bloc/products_bloc.dart';

class AddProductDialog extends StatefulWidget {
  const AddProductDialog({Key? key}) : super(key: key);

  @override
  _AddProductDialogState createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Form fields
  String? _selectedCategory;
  String? _productName;
  double? _price;
  double? _discountPrice;
  int? _stockQuantity;
  String? _sku;
  String? _description;

  // Image handling
  List<File> _selectedImages = [];
  List<String> _uploadedImageUrls = [];
  bool _isUploading = false;

  Future<void> _pickImages() async {
    try {
      final List<XFile>? images = await _picker.pickMultiImage();
      if (images != null && images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images.map((xFile) => File(xFile.path)));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking images: $e')),
      );
    }
  }

  Future<List<String>> _uploadImages() async {
    List<String> imageUrls = [];

    for (var i = 0; i < _selectedImages.length; i++) {
      File imageFile = _selectedImages[i];
      String fileName =
          'product_${DateTime.now().millisecondsSinceEpoch}_${i}_${path.basename(imageFile.path)}';

      try {
        Reference storageRef =
            FirebaseStorage.instance.ref().child('products').child(fileName);

        // Upload file
        await storageRef.putFile(
          imageFile,
          SettableMetadata(contentType: 'image/jpeg'),
        );

        // Get download URL
        String downloadUrl = await storageRef.getDownloadURL();
        imageUrls.add(downloadUrl);
      } catch (e) {
        throw Exception('Failed to upload image: $e');
      }
    }

    return imageUrls;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Container(
          constraints:
              BoxConstraints(maxWidth: 500), // Maximum width for larger screens
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Add Product',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Image Selection Section
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: _selectedImages.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.image_outlined,
                                        size: 40, color: Colors.grey.shade400),
                                    const SizedBox(height: 8),
                                    Text('No images selected',
                                        style: TextStyle(
                                            color: Colors.grey.shade600)),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _selectedImages.length,
                                padding: const EdgeInsets.all(8),
                                itemBuilder: (context, index) {
                                  return Stack(
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(right: 8),
                                        width: 120,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          image: DecorationImage(
                                            image: FileImage(
                                                _selectedImages[index]),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        child: IconButton(
                                          icon: const Icon(Icons.cancel,
                                              color: Colors.red),
                                          onPressed: () {
                                            setState(() {
                                              _selectedImages.removeAt(index);
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton.icon(
                          onPressed: _pickImages,
                          icon: const Icon(Icons.add_photo_alternate),
                          label: const Text('Add Images'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 44),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Category Dropdown
                BlocBuilder<CategoriesBloc, CategoriesState>(
                  builder: (context, state) {
                    if (state is CategoriesLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is CategoriesLoaded) {
                      return DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: state.categories
                            .map(
                                (Category category) => DropdownMenuItem<String>(
                                      value: category.id,
                                      child: Text(category.name),
                                    ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                        validator: (value) =>
                            value == null ? 'Please select a category' : null,
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 16),

                // Product Details Form Fields
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Product Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) => _productName = value,
                  validator: (value) =>
                      value?.isEmpty == true ? 'Enter product name' : null,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Price',
                          prefixText: 'Ksh ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => _price = double.tryParse(value),
                        validator: (value) =>
                            value?.isEmpty == true ? 'Enter price' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Discount Price',
                          prefixText: 'Ksh ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) =>
                            _discountPrice = double.tryParse(value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Stock Quantity',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) =>
                            _stockQuantity = int.tryParse(value),
                        validator: (value) => value?.isEmpty == true
                            ? 'Enter stock quantity'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'SKU',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (value) => _sku = value,
                        validator: (value) =>
                            value?.isEmpty == true ? 'Enter SKU' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 3,
                  onChanged: (value) => _description = value,
                  validator: (value) =>
                      value?.isEmpty == true ? 'Enter description' : null,
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: _isUploading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            if (_selectedImages.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Please select at least one image'),
                                ),
                              );
                              return;
                            }

                            setState(() {
                              _isUploading = true;
                            });

                            try {
                              // Upload images
                              _uploadedImageUrls = await _uploadImages();

                              // Create product document ID
                              final String productId = FirebaseFirestore
                                  .instance
                                  .collection('products')
                                  .doc()
                                  .id;

                              // Create product model
                              final newProduct = ProductModel(
                                id: productId,
                                productName: _productName!,
                                imageUrls: _uploadedImageUrls,
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

                              // Add product to database
                              context
                                  .read<ProductsBloc>()
                                  .add(AddProduct(newProduct));

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
                                  content: Text('Error: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            } finally {
                              setState(() {
                                _isUploading = false;
                              });
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isUploading
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

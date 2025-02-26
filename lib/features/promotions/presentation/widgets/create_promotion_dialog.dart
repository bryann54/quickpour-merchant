

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:quickpourmerchant/features/brands/data/models/brands_model.dart';
import 'package:quickpourmerchant/features/categories/domain/entities/category.dart';
import 'package:quickpourmerchant/features/product/data/models/product_model.dart';
import 'package:quickpourmerchant/features/promotions/data/models/promotion_model.dart';
import 'package:quickpourmerchant/features/promotions/presentation/bloc/promotions_bloc.dart';
import 'package:quickpourmerchant/features/promotions/presentation/bloc/promotions_event.dart';

class CreatePromotionDialog extends StatefulWidget {
  const CreatePromotionDialog({super.key});

  @override
  State<CreatePromotionDialog> createState() => _CreatePromotionDialogState();
}

class _CreatePromotionDialogState extends State<CreatePromotionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  // Controllers
  final _discountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _titleController = TextEditingController();

  // Form state
  String? _imageUrl;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  String _promotionType = 'flash_sale';
  bool _isActive = true;
  String _searchQuery = '';

  PromotionTarget _promotionTarget = PromotionTarget.products;
  bool _isLoading = false;

  // Selection state
  List<String> _selectedProducts = [];
  List<String> _selectedCategories = [];
  List<String> _selectedBrands = [];

  // Cache for loaded data
  List<MerchantProductModel>? _cachedProducts;
  List<BrandModel>? _cachedBrands;

  @override
  void dispose() {
    _discountController.dispose();
    _descriptionController.dispose();
    _titleController.dispose();
    super.dispose();
  }

// Data fetching methods with caching
  Future<List<MerchantProductModel>> _fetchProducts() async {
    if (_cachedProducts != null) return _cachedProducts!;

    try {
      final snapshot = await _firestore.collection('products').get();
      _cachedProducts = snapshot.docs
          .map((doc) => MerchantProductModel.fromMap(
            doc.data(),
          ))
          .toList();
      return _cachedProducts!;
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  Future<List<Category>> _fetchCategories() async {
    final snapshot = await _firestore.collection('categories').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Category(
        id: doc.id,
        name: data['name'],
        imageUrl: data['imageUrl'],
        // Add other fields as needed
      );
    }).toList();
  }

  Future<List<BrandModel>> _fetchBrands() async {
    if (_cachedBrands != null) return _cachedBrands!;

    try {
      final snapshot = await _firestore.collection('brands').get();
      _cachedBrands = snapshot.docs
          .map((doc) => BrandModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
      return _cachedBrands!;
    } catch (e) {
      throw Exception('Failed to fetch brands: $e');
    }
  }

  // Image upload handling
  Future<void> _handleImageUpload() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) return;

      setState(() {
        _isLoading = true;
      });

      // Upload to Firebase Storage
      final storageRef = _storage
          .ref()
          .child('promotions/${DateTime.now().millisecondsSinceEpoch}');
      final uploadTask = await storageRef.putData(await image.readAsBytes());
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      setState(() {
        _imageUrl = downloadUrl;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('Failed to upload image: $e');
    }
  }

  // Validation
  bool _validateForm() {
    if (!_formKey.currentState!.validate()) return false;

    switch (_promotionTarget) {
      case PromotionTarget.products:
        if (_selectedProducts.isEmpty) {
          _showErrorDialog('Please select at least one product');
          return false;
        }
        break;
      case PromotionTarget.categories:
        if (_selectedCategories.isEmpty) {
          _showErrorDialog('Please select at least one category');
          return false;
        }
        break;
      case PromotionTarget.brands:
        if (_selectedBrands.isEmpty) {
          _showErrorDialog('Please select at least one brand');
          return false;
        }
        break;
    }

    if (_startDate.isAfter(_endDate)) {
      _showErrorDialog('Start date must be before end date');
      return false;
    }

    return true;
  }

  Future<void> _submitForm() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);

    try {
      final promotion = MerchantPromotionModel(
        merchantId: 'your_merchant_id_here',
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productIds: _selectedProducts,
        categoryIds: _selectedCategories,
        brandIds: _selectedBrands,
        discountPercentage: double.parse(_discountController.text),
        startDate: _startDate,
        endDate: _endDate,
        isActive: _isActive,
        description: _descriptionController.text,
        promotionType: _promotionType,
        campaignTitle: _titleController.text,
        imageUrl: _imageUrl,
        promotionTarget: _promotionTarget,
      );

      context.read<PromotionsBloc>().add(CreatePromotion(promotion));

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Promotion created successfully')),
        );
      }
    } catch (e) {
      _showErrorDialog('Failed to create promotion: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

@override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Container(
                        width: constraints.maxWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildHeader(),
                            const Divider(),
                            const SizedBox(height: 16),
                            _buildImageUploadSection(),
                            const SizedBox(height: 16),
                            _buildBasicInformationSection(),
                            const SizedBox(height: 16),
                            _buildPromotionDetailsSection(),
                            const SizedBox(height: 16),
                            _buildTargetSelectionSection(),
                            const SizedBox(height: 24),
                            _buildActionButtons(),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            const Positioned.fill(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Create New Promotion',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildImageUploadSection() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _imageUrl != null
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _imageUrl!,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => setState(() => _imageUrl = null),
                        ),
                      ),
                    ],
                  )
                : InkWell(
                    onTap: _handleImageUpload,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 50,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text('Click to upload image'),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInformationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Basic Information',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Campaign Title',
            border: OutlineInputBorder(),
            hintText: 'Enter campaign title',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter campaign title';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _discountController,
          decoration: const InputDecoration(
            labelText: 'Discount Percentage',
            border: OutlineInputBorder(),
            suffixText: '%',
            hintText: 'Enter discount percentage',
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter discount percentage';
            }
            final discount = double.tryParse(value);
            if (discount == null || discount <= 0 || discount > 100) {
              return 'Please enter a valid discount (1-100)';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description',
            border: OutlineInputBorder(),
            hintText: 'Enter promotion description',
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter description';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPromotionDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Promotion Details',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDateSelector(
                title: 'Start Date',
                selectedDate: _startDate,
                onSelect: (date) => setState(() => _startDate = date),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDateSelector(
                title: 'End Date',
                selectedDate: _endDate,
                onSelect: (date) => setState(() => _endDate = date),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _promotionType,
          decoration: const InputDecoration(
            labelText: 'Promotion Type',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'flash_sale', child: Text('Flash Sale')),
            DropdownMenuItem(value: 'seasonal', child: Text('Seasonal')),
            DropdownMenuItem(value: 'clearance', child: Text('Clearance')),
            DropdownMenuItem(value: 'bundle', child: Text('Bundle Deal')),
            DropdownMenuItem(value: 'holiday', child: Text('Holiday Special')),
          ],
          onChanged: (value) => setState(() => _promotionType = value!),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<PromotionTarget>(
          value: _promotionTarget,
          decoration: const InputDecoration(
            labelText: 'Promotion Target',
            border: OutlineInputBorder(),
          ),
          items: PromotionTarget.values.map((target) {
            return DropdownMenuItem(
              value: target,
              child: Text(target.toString().split('.').last.toUpperCase()),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _promotionTarget = value!;
              _selectedProducts = [];
              _selectedCategories = [];
              _selectedBrands = [];
            });
          },
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Active Status'),
          subtitle: const Text('Enable or disable this promotion'),
          value: _isActive,
          onChanged: (value) => setState(() => _isActive = value),
        ),
      ],
    );
  }

  Widget _buildDateSelector({
    required String title,
    required DateTime selectedDate,
    required Function(DateTime) onSelect,
  }) {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) onSelect(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: title,
          border: const OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat('MMM dd, yyyy').format(selectedDate)),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetSelectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select ${_promotionTarget.toString().split('.').last}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        _buildTargetSelectionContent(),
      ],
    );
  }

  Widget _buildTargetSelectionContent() {
    switch (_promotionTarget) {
      case PromotionTarget.products:
        return _buildProductSelector();
      case PromotionTarget.categories:
        return _buildCategorySelector();
      case PromotionTarget.brands:
        return _buildBrandSelector();
    }
  }

  Widget _buildProductSelector() {
    return FutureBuilder<List<MerchantProductModel>>(
      future: _fetchProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading products: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No products available'),
          );
        }

        List<MerchantProductModel> allProducts = snapshot.data!;
        List<MerchantProductModel> displayedProducts = _searchQuery.isEmpty
            ? (allProducts..shuffle()).take(5).toList()
            : allProducts
                .where((product) => product.productName
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()))
                .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Search Products',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: displayedProducts.map((product) {
                return FilterChip(
                  label: Text(product.productName),
                  selected: _selectedProducts.contains(product.id),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedProducts.add(product.id);
                      } else {
                        _selectedProducts.remove(product.id);
                      }
                    });
                  },
                  avatar: product.imageUrls.isNotEmpty
                      ? CircleAvatar(
                          backgroundImage:
                              NetworkImage(product.imageUrls.first),
                        )
                      : null,
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategorySelector() {
    return FutureBuilder<List<Category>>(
      future: _fetchCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading categories: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No categories available'),
          );
        }

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: snapshot.data!.map((category) {
            return FilterChip(
              label: Text(category.name),
              selected: _selectedCategories.contains(category.id),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedCategories.add(category.id);
                  } else {
                    _selectedCategories.remove(category.id);
                  }
                });
              },
              avatar: CircleAvatar(
                backgroundImage: NetworkImage(category.imageUrl),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildBrandSelector() {
    return FutureBuilder<List<BrandModel>>(
      future: _fetchBrands(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading brands: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No brands available'),
          );
        }

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: snapshot.data!.map((brand) {
            return FilterChip(
                label: Text(brand.name),
                selected: _selectedBrands.contains(brand.id),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedBrands.add(brand.id);
                    } else {
                      _selectedBrands.remove(brand.id);
                    }
                  });
                },
                avatar: CircleAvatar(
                  backgroundImage: NetworkImage(brand.logoUrl),
                ));
          }).toList(),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitForm,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create Promotion'),
        ),
      ],
    );
  }
}

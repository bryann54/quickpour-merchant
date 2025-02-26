import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quickpourmerchant/features/promotions/data/models/promotion_model.dart';
import 'package:quickpourmerchant/features/promotions/presentation/bloc/promotions_bloc.dart';
import 'package:quickpourmerchant/features/promotions/presentation/bloc/promotions_event.dart';
import 'package:quickpourmerchant/features/promotions/presentation/widgets/promotion_image_upload.dart';
import 'package:quickpourmerchant/features/promotions/presentation/widgets/promotion_basic_info.dart';
import 'package:quickpourmerchant/features/promotions/presentation/widgets/promotion_details.dart';
import 'package:quickpourmerchant/features/promotions/presentation/widgets/promotion_target_selector.dart';
import 'package:quickpourmerchant/features/promotions/presentation/widgets/promotion_action_buttons.dart';
import 'package:quickpourmerchant/features/promotions/presentation/widgets/promotion_product_selector.dart';
import 'package:quickpourmerchant/features/promotions/presentation/widgets/promotion_category_selector.dart';
import 'package:quickpourmerchant/features/promotions/presentation/widgets/promotion_brand_selector.dart';
import 'package:quickpourmerchant/features/product/data/models/product_model.dart';
import 'package:quickpourmerchant/features/categories/domain/entities/category.dart';
import 'package:quickpourmerchant/features/brands/data/models/brands_model.dart';

class CreatePromotionPage extends StatefulWidget {
  const CreatePromotionPage({super.key});

  @override
  State<CreatePromotionPage> createState() => _CreatePromotionPageState();
}

class _CreatePromotionPageState extends State<CreatePromotionPage> {
  final _formKey = GlobalKey<FormState>();
  final _discountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _titleController = TextEditingController();

  String? _imageUrl;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  String _promotionType = 'flash_sale';
  bool _isActive = true;
  PromotionTarget _promotionTarget = PromotionTarget.products;
  bool _isLoading = false;

  List<String> _selectedProducts = [];
  List<String> _selectedCategories = [];
  List<String> _selectedBrands = [];

  // Cached data
  List<MerchantProductModel> _cachedProducts = [];
  List<Category> _cachedCategories = [];
  List<BrandModel> _cachedBrands = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _discountController.dispose();
    _descriptionController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);

    try {
      final products = await _fetchProducts();
      final categories = await _fetchCategories();
      final brands = await _fetchBrands();

      setState(() {
        _cachedProducts = products;
        _cachedCategories = categories;
        _cachedBrands = brands;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch data: $e')),
        );
      }
    }
  }

  Future<List<MerchantProductModel>> _fetchProducts() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('products').get();
    return snapshot.docs
        .map((doc) => MerchantProductModel.fromMap(doc.data()))
        .toList();
  }

  Future<List<Category>> _fetchCategories() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('categories').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Category(
        id: doc.id,
        name: data['name'],
        imageUrl: data['imageUrl'],
      );
    }).toList();
  }

  String? get _merchantId => FirebaseAuth.instance.currentUser?.uid;

  Future<List<BrandModel>> _fetchBrands() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('brands').get();
    return snapshot.docs
        .map((doc) => BrandModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final promotion = MerchantPromotionModel(
        merchantId: _merchantId.toString(),
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
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Promotion'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PromotionImageUpload(
                      imageUrl: _imageUrl,
                      onImageUpload: (url) => setState(() => _imageUrl = url),
                    ),
                    const SizedBox(height: 16),
                    PromotionBasicInfo(
                      titleController: _titleController,
                      discountController: _discountController,
                      descriptionController: _descriptionController,
                    ),
                    const SizedBox(height: 16),
                    PromotionDetails(
                      startDate: _startDate,
                      endDate: _endDate,
                      promotionType: _promotionType,
                      isActive: _isActive,
                      onStartDateChanged: (date) =>
                          setState(() => _startDate = date),
                      onEndDateChanged: (date) =>
                          setState(() => _endDate = date),
                      onPromotionTypeChanged: (type) =>
                          setState(() => _promotionType = type),
                      onActiveStatusChanged: (value) =>
                          setState(() => _isActive = value),
                    ),
                    const SizedBox(height: 16),
                    PromotionTargetSelector(
                      promotionTarget: _promotionTarget,
                      onTargetChanged: (target) =>
                          setState(() => _promotionTarget = target),
                    ),
                    const SizedBox(height: 16),
                    if (_promotionTarget == PromotionTarget.products)
                      PromotionProductSelector(
                        merchantId: _merchantId.toString(),
                        selectedProducts: _selectedProducts,
                        products: _cachedProducts,
                        onProductSelected: (productId, selected) {
                          setState(() {
                            if (selected) {
                              _selectedProducts.add(productId);
                            } else {
                              _selectedProducts.remove(productId);
                            }
                          });
                        },
                      ),
                    if (_promotionTarget == PromotionTarget.categories)
                      PromotionCategorySelector(
                        selectedCategories: _selectedCategories,
                        categories: _cachedCategories,
                        onCategorySelected: (categoryId, selected) {
                          setState(() {
                            if (selected) {
                              _selectedCategories.add(categoryId);
                            } else {
                              _selectedCategories.remove(categoryId);
                            }
                          });
                        },
                      ),
                    if (_promotionTarget == PromotionTarget.brands)
                      PromotionBrandSelector(
                        merchantId: _merchantId.toString(),
                        selectedBrands: _selectedBrands,
                        brands: _cachedBrands,
                        onBrandSelected: (brandId, selected) {
                          setState(() {
                            if (selected) {
                              _selectedBrands.add(brandId);
                            } else {
                              _selectedBrands.remove(brandId);
                            }
                          });
                        },
                      ),
                    const SizedBox(height: 24),
                    PromotionActionButtons(
                      isLoading: _isLoading,
                      onCancel: () => Navigator.pop(context),
                      onSubmit: _submitForm,
                    ),
                    const SizedBox(height: 24), // Bottom padding
                  ],
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
}

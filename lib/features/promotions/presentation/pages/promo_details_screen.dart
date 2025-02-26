import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:quickpourmerchant/features/promotions/data/models/promotion_model.dart';

class PromoDetailsScreen extends StatefulWidget {
  final MerchantPromotionModel promotion;
  final List<AdminProductModel>? prefetchedProducts;

  const PromoDetailsScreen({
    super.key,
    required this.promotion,
    this.prefetchedProducts,
  });

  @override
  State<PromoDetailsScreen> createState() => _PromoDetailsScreenState();
}

class AdminProductModel {
  final String id;
  final String productName;
  final double price;
  final List<String> imageUrls;

  AdminProductModel({
    required this.id,
    required this.productName,
    required this.price,
    required this.imageUrls,
  });

  factory AdminProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdminProductModel(
      id: doc.id,
      productName: data['productName'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
    );
  }
}

class _PromoDetailsScreenState extends State<PromoDetailsScreen> {
  List<AdminProductModel> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.prefetchedProducts != null) {
      setState(() {
        _products = widget.prefetchedProducts!;
        _isLoading = false;
      });
    } else {
      _loadPromotionProducts();
    }
  }

  Future<void> _loadPromotionProducts() async {
    setState(() => _isLoading = true);
    try {
      final products = await _fetchPromotionProducts();
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('Failed to load products: $e');
    }
  }

  Future<List<AdminProductModel>> _fetchPromotionProducts() async {
    final firestore = FirebaseFirestore.instance;

    switch (widget.promotion.promotionTarget) {
      case PromotionTarget.products:
        if (widget.promotion.productIds.isEmpty) return [];

        final snapshots = await Future.wait(
          widget.promotion.productIds.map(
            (id) => firestore.collection('products').doc(id).get(),
          ),
        );

        return snapshots
            .where((doc) => doc.exists)
            .map((doc) => AdminProductModel.fromFirestore(doc))
            .toList();

      case PromotionTarget.categories:
        if (widget.promotion.categoryIds.isEmpty) return [];

        final snapshot = await firestore
            .collection('products')
            .where('categoryId', whereIn: widget.promotion.categoryIds)
            .get();

        return snapshot.docs
            .map((doc) => AdminProductModel.fromFirestore(doc))
            .toList();

      case PromotionTarget.brands:
        if (widget.promotion.brandIds.isEmpty) return [];

        final snapshot = await firestore
            .collection('products')
            .where('brandId', whereIn: widget.promotion.brandIds)
            .get();

        return snapshot.docs
            .map((doc) => AdminProductModel.fromFirestore(doc))
            .toList();

      default:
        return [];
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getTargetLabel(MerchantPromotionModel promotion) {
    if (promotion.productIds.isNotEmpty) {
      return '${promotion.productIds.length} Products';
    } else if (promotion.categoryIds.isNotEmpty) {
      return '${promotion.categoryIds.length} Categories';
    } else if (promotion.brandIds.isNotEmpty) {
      return '${promotion.brandIds.length} Brands';
    }
    return 'General Promotion';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.promotion.campaignTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Implement navigation to edit screen
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPromotionHeader(isDarkMode),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPromotionDetails(isDarkMode),
                        const SizedBox(height: 24),
                        _buildProductsGrid(isDarkMode),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProductsGrid(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Promoted Products',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _products.isEmpty
            ? Center(
                child: Text(
                  'No products found for this promotion',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                ),
              )
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _products.length,
                itemBuilder: (context, index) => _buildProductCard(
                  _products[index],
                  isDarkMode,
                ),
              ),
      ],
    );
  }

  Widget _buildProductCard(AdminProductModel product, bool isDarkMode) {
    final discountedPrice =
        product.price * (1 - widget.promotion.discountPercentage / 100);

    return Card(
      elevation: 5,
      shadowColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: CachedNetworkImage(
                imageUrl: product.imageUrls.isNotEmpty
                    ? product.imageUrls.first
                    : 'assets/product_placeholder.png',
                fit: BoxFit.cover,
                width: double.infinity,
                errorWidget: (context, url, error) => Container(
                  color:
                      isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '\$${discountedPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14,
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionHeader(bool isDarkMode) {
    return Stack(
      children: [
        CachedNetworkImage(
          imageUrl:
              widget.promotion.imageUrl ?? 'assets/promotion_placeholder.png',
          fit: BoxFit.cover,
          width: double.infinity,
          height: 250,
          errorWidget: (context, url, error) => Container(
            width: double.infinity,
            height: 250,
            color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
            child: const Icon(Icons.image_not_supported),
          ),
        ),
        Positioned(
          top: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: widget.promotion.isActive ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.promotion.isActive ? 'Active' : 'Inactive',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPromotionDetails(bool isDarkMode) {
    return Card(
      elevation: 5,
      shadowColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.promotion.campaignTitle,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.promotion.promotionType} | ${_getTargetLabel(widget.promotion)}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.promotion.description,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

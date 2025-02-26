import 'package:flutter/material.dart';
import 'package:quickpourmerchant/features/product/data/models/product_model.dart';

class PromotionProductSelector extends StatefulWidget {
  final List<String> selectedProducts;
  final List<MerchantProductModel> products;
  final Function(String, bool) onProductSelected;
  final String merchantId; 

  const PromotionProductSelector({
    super.key,
    required this.selectedProducts,
    required this.products,
    required this.onProductSelected,
    required this.merchantId,
  });

  @override
  State<PromotionProductSelector> createState() =>
      _PromotionProductSelectorState();
}

class _PromotionProductSelectorState extends State<PromotionProductSelector> {
  String _searchQuery = '';
  late List<MerchantProductModel> _merchantProducts;

  @override
  void initState() {
    super.initState();
    // Filter products by merchantId when widget initializes
    _filterProductsByMerchantId();
  }

  @override
  void didUpdateWidget(PromotionProductSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-filter products if either products list or merchantId changes
    if (oldWidget.products != widget.products ||
        oldWidget.merchantId != widget.merchantId) {
      _filterProductsByMerchantId();
    }
  }

  void _filterProductsByMerchantId() {
    _merchantProducts = widget.products
        .where((product) => product.merchantId == widget.merchantId)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    // Apply search filter on the already merchant-filtered products
    final displayedProducts = _searchQuery.isEmpty
        ? _merchantProducts
        : _merchantProducts
            .where((product) => product.productName
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Products',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
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
        displayedProducts.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text('No products found for this merchant'),
                ),
              )
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: displayedProducts.map((product) {
                  return FilterChip(
                    label: Text(product.productName),
                    selected: widget.selectedProducts.contains(product.id),
                    onSelected: (selected) =>
                        widget.onProductSelected(product.id, selected),
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
  }
}

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quickpourmerchant/core/utils/colors.dart';
import 'package:quickpourmerchant/features/product/data/models/product_model.dart';
import 'package:quickpourmerchant/features/product/presentation/pages/product_details_screen.dart';

class ProductCard extends StatelessWidget {
  final MerchantProductModel product;

  const ProductCard({Key? key, required this.product}) : super(key: key);
  int _calculateDiscountPercentage(double originalPrice, double discountPrice) {
    if (originalPrice <= 0 || discountPrice <= 0) return 0;
    return ((originalPrice - discountPrice) / originalPrice * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(product: product),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image or Placeholder
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (product.imageUrls.isNotEmpty)
                      Hero(
                        tag: 'productImage_${product.id}',
                        child: Image.network(
                          product.imageUrls.first,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(child: Icon(Icons.error_outline)),
                        ),
                      )
                    else
                      Hero(
                        tag: 'productImage_${product.id}',
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: isDarkMode
                                    ? AppColors.accentColor.withOpacity(.5)
                                    : AppColors.accentColorDark
                                        .withOpacity(.3)),
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12)),
                          ),
                          child: Container(
                            color: isDarkMode
                                ? Colors.grey.shade900
                                : Colors.grey.shade200,
                            height: 130,
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FaIcon(
                                    Icons.error,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    // Discount Percentage Tag (Only appears if there's a discount)
                    if (product.discountPrice > 0)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Hero(
                          tag: 'discount_${product.id}',
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.orange, AppColors.primaryColor],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              // borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(2, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Icon(
                                  FontAwesomeIcons.tag,
                                  color: Colors.white,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${_calculateDiscountPercentage(product.price, product.discountPrice)}% OFF',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Product Details
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: 'product_name_${product.id}',
                      child: Material(
                        child: Text(
                          product.productName,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor.withOpacity(.7)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product.discountPrice > 0
                              ? 'Ksh ${product.discountPrice.toStringAsFixed(0)}'
                              : 'Ksh ${product.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        if (product.discountPrice > 0)
                          Text(
                            'Ksh ${product.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 12,
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                    Column(
                      children: [
                        if (product.stockQuantity <= 5)
                          Text(
                            'Low Stock (${product.stockQuantity} remaining)',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.orange,
                            ),
                          ),
                        Text(
                          product.isAvailable ? 'In Stock' : 'Out of Stock',
                          style: TextStyle(
                            fontSize: 12,
                            color: product.isAvailable
                                ? (product.stockQuantity <= 5
                                    ? Colors.orange
                                    : Colors.green)
                                : Colors.red,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

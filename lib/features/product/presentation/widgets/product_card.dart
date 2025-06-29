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
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: IntrinsicHeight(
       
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.stretch, 
            children: [
              // Product Image
              Container(
                width: 100, // Fixed width for the image
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.horizontal(left: Radius.circular(12)),
                  color:
                      isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200,
                ),
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.horizontal(left: Radius.circular(12)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (product.imageUrls.isNotEmpty)
                        Hero(
                          tag: 'productImage_${product.id}',
                          child: Image.network(
                            product.imageUrls.first,
                            fit: BoxFit.cover, // Use cover to fill the space
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(
                                    child: Icon(Icons.broken_image_outlined,
                                        size: 40, color: Colors.grey)),
                          ),
                        )
                      else
                        Hero(
                          tag: 'productImage_${product.id}',
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isDarkMode
                                    ? AppColors.accentColor.withOpacity(0.5)
                                    : AppColors.accentColorDark
                                        .withOpacity(0.3),
                              ),
                              borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(12)),
                            ),
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons
                                        .solidImage, // More appropriate icon for missing image
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 8),
                                  Text("No Image",
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 10)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      // Discount Percentage Tag
                      if (product.discountPrice > 0 &&
                          product.discountPrice < product.price)
                        Positioned(
                          top: 8,
                          left: 8, 
                          child: Hero(
                            tag: 'discount_${product.id}',
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Colors.orange,
                                    AppColors.primaryColor
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(
                                    6), // Slightly rounded corners
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 3,
                                    offset: const Offset(1, 1),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize:
                                    MainAxisSize.min, // Keep row content tight
                                children: [
                                  const Icon(
                                    FontAwesomeIcons.tag,
                                    color: Colors.white,
                                    size: 10, // Smaller icon
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${_calculateDiscountPercentage(product.price, product.discountPrice)}% OFF',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
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
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Hero(
                        tag: 'product_name_${product.id}',
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            product.productName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor.withOpacity(0.8),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.categoryName,
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            product.discountPrice > 0
                                ? 'Ksh ${product.discountPrice.toStringAsFixed(0)}'
                                : 'Ksh ${product.price.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: product.discountPrice > 0
                                  ? Colors.green.shade700
                                  : theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                          if (product.discountPrice > 0 &&
                              product.discountPrice < product.price)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                'Ksh ${product.price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          const Spacer(), // Pushes the measure to the right
                          Text(
                            product.measure, // Display the measure
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment
                            .bottomRight, // Align stock status to the bottom right
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (product.stockQuantity > 0 &&
                                product.stockQuantity <= 5)
                              Text(
                                'Low Stock (${product.stockQuantity} remaining)',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            Text(
                              product.isAvailable ? 'In Stock' : 'Out of Stock',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: product.isAvailable
                                    ? (product.stockQuantity > 5
                                        ? Colors.green
                                        : Colors.orange)
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

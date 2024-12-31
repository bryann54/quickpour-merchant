import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quickpourmerchant/features/product/data/models/product_model.dart';
import 'package:quickpourmerchant/features/product/presentation/pages/product_details_screen.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            // Product Image with Hero
            if (product.imageUrls.isNotEmpty)
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'productImage_${product.id}',
                        child: Image.network(
                          product.imageUrls.first,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(
                            child: Icon(Icons.error_outline),
                          ),
                        ),
                      ),
                      if (product.discountPrice > 0)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${(100 - ((product.discountPrice / product.price) * 100)).round()}% OFF',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              )
            else
              const SizedBox(
                height: 150,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FaIcon(FontAwesomeIcons.accusoft, size: 50,color: Colors.grey,),
                      Text('no image available')
                    ],
                  ),
                ),
              ),
            // Product Details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.productName,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      product.discountPrice > 0
                          ? '\Ksh ${product.discountPrice.toStringAsFixed(2)}'
                          : '\Ksh ${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    if (product.discountPrice > 0)
                      Text(
                        '\ksh ${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 12,
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                      ),
                    Text(
                      product.isAvailable ? 'In Stock' : 'Out of Stock',
                      style: TextStyle(
                        fontSize: 12,
                        color: product.isAvailable ? Colors.green : Colors.red,
                      ),
                    ),
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

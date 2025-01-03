// lib/features/product/presentation/widgets/product_info.dart
import 'package:flutter/material.dart';
import 'package:quickpourmerchant/features/product/data/models/product_model.dart';

class ProductInfo extends StatelessWidget {
  final ProductModel product;

  const ProductInfo({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       
        const SizedBox(height: 8),
        _buildDatesRow(context),
      ],
    );
  }



  Widget _buildDatesRow(BuildContext context) {
    return     Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Created: ${product.createdAt.toString()}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            Expanded(
              child: Text(
                'Updated: ${product.updatedAt.toString()}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        );
  }
}

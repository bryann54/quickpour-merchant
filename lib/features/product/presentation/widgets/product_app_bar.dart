// lib/features/product/presentation/widgets/product_app_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickpourmerchant/core/utils/colors.dart';
import 'package:quickpourmerchant/features/product/data/models/product_model.dart';
import 'package:quickpourmerchant/core/utils/strings.dart';
import 'package:quickpourmerchant/features/product/presentation/bloc/products_bloc.dart';
import 'package:quickpourmerchant/features/product/presentation/widgets/product_image_gallery.dart';

class ProductAppBar extends StatelessWidget {
  final MerchantProductModel product;
  final bool isEditing;
  final VoidCallback onEditPressed;

  const ProductAppBar({
    Key? key,
    required this.product,
    required this.isEditing,
    required this.onEditPressed,
  }) : super(key: key);
  int _calculateDiscountPercentage(double originalPrice, double discountPrice) {
    if (originalPrice <= 0 || discountPrice <= 0) return 0;
    return ((originalPrice - discountPrice) / originalPrice * 100).round();
  }
  @override
  Widget build(BuildContext context) {
 
    return SliverAppBar(
      expandedHeight: 400.0,
      floating: false,
      pinned: true,
      iconTheme: const IconThemeData(color: AppColors.accentColor),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          isEditing ? edit : product_details,
          style: Theme.of(context).textTheme.displayLarge,
        ),
        background: ProductImageGallery(product: product),
      ),
      actions: [
        IconButton.filled(

          icon: Icon(isEditing ? Icons.save : Icons.edit),
          onPressed: onEditPressed,
          color: AppColors.accentColor,
        ),
        if (!isEditing)
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: Colors.red,
            onPressed: () => _showDeleteDialog(context),
          ),
      ],
    );
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    final bool confirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog.adaptive(
            title: const Text(delete_product),
            content: const Text(delete_product_txt),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(cancel),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, true),
                child: const Text(delete),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      _deleteProduct(context);
    }
  }

  Future<void> _deleteProduct(BuildContext context) async {
    try {
      context.read<ProductsBloc>().add(DeleteProduct(product.id));
      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting product: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

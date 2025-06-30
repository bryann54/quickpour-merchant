import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280.0,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.black87),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        title: Text(
          isEditing ? edit : product_details,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        background: Stack(
          children: [
            ProductImageGallery(product: product),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(isEditing ? Icons.close : Icons.edit_outlined),
          onPressed: onEditPressed,
          tooltip: isEditing ? 'Cancel' : 'Edit',
        ),
        if (!isEditing)
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: Colors.red[400],
            onPressed: () => _showDeleteDialog(context),
            tooltip: 'Delete',
          ),
      ],
    );
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    final bool confirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text(delete_product),
            content: const Text(delete_product_txt),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(cancel),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red,
                ),
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
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

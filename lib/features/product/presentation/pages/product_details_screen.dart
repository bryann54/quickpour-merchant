import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickpourmerchant/features/product/presentation/bloc/products_bloc.dart';
import 'package:quickpourmerchant/features/product/data/models/product_model.dart';
import 'package:quickpourmerchant/features/product/presentation/widgets/product_app_bar.dart';
import 'package:quickpourmerchant/features/product/presentation/widgets/product_form.dart';

class ProductDetailsScreen extends StatefulWidget {
  final MerchantProductModel product;

  const ProductDetailsScreen({Key? key, required this.product})
      : super(key: key);

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  bool _isEditing = false;

  void _toggleEditing() {
    setState(() => _isEditing = !_isEditing);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductsBloc, ProductsState>(
      listener: (context, state) {
        if (state is ProductsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50], // Light background for contrast
        body: CustomScrollView(
          slivers: [
            ProductAppBar(
              product: widget.product,
              isEditing: _isEditing,
              onEditPressed: _toggleEditing,
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: ProductForm(
                  product: widget.product,
                  isEditing: _isEditing,
                  onUpdateComplete: _toggleEditing,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickpourmerchant/features/categories/presentation/bloc/categories_bloc.dart';
import 'package:quickpourmerchant/features/categories/presentation/bloc/categories_event.dart';
import 'package:quickpourmerchant/features/product/presentation/widgets/add_product_dialog_widget.dart';

class CustomFAB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        // Trigger fetching categories before showing the dialog
        context.read<CategoriesBloc>().add(LoadCategories());
        showDialog(
          context: context,
          builder: (context) => AddProductDialog(),
        );
      },
      icon: const Icon(Icons.add),
      label: const Text('Update inventory'),
      elevation: 15,
    );
  }
}

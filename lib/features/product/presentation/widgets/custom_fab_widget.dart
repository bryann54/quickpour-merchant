import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickpourmerchant/features/categories/presentation/bloc/categories_bloc.dart';
import 'package:quickpourmerchant/features/categories/presentation/bloc/categories_event.dart';
import 'package:quickpourmerchant/features/product/presentation/widgets/add_product_dialog_widget.dart';

class CustomFAB extends StatelessWidget {
  const CustomFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        
        context.read<CategoriesBloc>().add(LoadCategories());
        showDialog(
          context: context,
          builder: (context) => const AddProductDialog(),
        );
      },
      icon: const Icon(Icons.add),
      label: const Text('Add product'),
      elevation: 15,
    );
  }
}

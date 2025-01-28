import 'package:flutter/material.dart';
import 'package:quickpourmerchant/features/product/presentation/widgets/add_product_dialog_widget.dart';

class CustomFAB extends StatelessWidget {
  const CustomFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
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

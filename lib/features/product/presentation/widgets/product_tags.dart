// lib/features/product/presentation/widgets/product_tags.dart

import 'package:flutter/material.dart';

class ProductTags extends StatelessWidget {
  final List<String> tags;

  const ProductTags({Key? key, required this.tags}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: tags
          .map(
            (tag) => Chip(
              label: Text(tag),
              backgroundColor: Colors.blue,
            ),
          )
          .toList(),
    );
  }
}

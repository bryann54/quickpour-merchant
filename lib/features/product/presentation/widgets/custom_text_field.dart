// lib/features/product/presentation/widgets/custom_text_field.dart

import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool enabled;
  final int maxLines;
  final TextInputType keyboardType;
  final TextStyle? style;

  const CustomTextField({
    Key? key,
    required this.label,
    required this.controller,
    required this.enabled,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: style,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

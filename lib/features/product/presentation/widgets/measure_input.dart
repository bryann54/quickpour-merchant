import 'package:flutter/material.dart';

class MeasureInputField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool isEnabled;

  const MeasureInputField({
    super.key,
    required this.controller,
    this.focusNode,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      enabled: isEnabled,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Measure',
        hintText: 'e.g., 750ml, 1L, 70cl',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: const Icon(Icons.liquor),
        suffixIcon: IconButton(
          icon: const Icon(Icons.help_outline),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Measure Guidelines'),
                content: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Common measures:'),
                    SizedBox(height: 8),
                    Text('• ml - milliliters (e.g., 750ml)'),
                    Text('• L - liters (e.g., 1L)'),
                    Text('• cl - centiliters (e.g., 70cl)'),
                    SizedBox(height: 16),
                    Text(
                        'Please enter the measure in the format: number + unit'),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Got it'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter the measure';
        }

        // Pattern to match number followed by unit (ml, L, cl)
        final pattern =
            RegExp(r'^\d+(\.\d+)?\s*(ml|L|cl)$', caseSensitive: false);

        if (!pattern.hasMatch(value.trim())) {
          return 'Invalid format. Use: number + unit (e.g., 750ml)';
        }

        return null;
      },
      onChanged: (value) {
        // Convert to lowercase unit automatically
        if (value.isNotEmpty) {
          final normalized = value.replaceAllMapped(
            RegExp(r'(ml|l|cl)$', caseSensitive: false),
            (match) => match.group(0)!.toLowerCase(),
          );
          if (normalized != value) {
            controller.value = controller.value.copyWith(
              text: normalized,
              selection: TextSelection.collapsed(offset: normalized.length),
            );
          }
        }
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}

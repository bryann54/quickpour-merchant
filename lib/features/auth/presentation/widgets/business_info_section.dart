// lib/features/auth/presentation/widgets/business_information_section.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickpourmerchant/features/auth/presentation/widgets/app_text_field.dart';
import 'package:quickpourmerchant/features/auth/presentation/widgets/location_picker_field.dart';

class BusinessInformationSection extends StatelessWidget {
  final TextEditingController storeNameController;
  final TextEditingController locationController;
  final bool isDarkMode;

  const BusinessInformationSection({
    Key? key,
    required this.storeNameController,
    required this.locationController,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Business Information',
            style: GoogleFonts.acme(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: storeNameController,
            labelText: 'Store Name',
            prefixIcon: Icons.store_outlined,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter store name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          LocationPickerField(
            controller: locationController,
          ),
        ],
      ),
    );
  }
}

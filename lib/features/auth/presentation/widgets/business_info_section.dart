// lib/features/auth/presentation/widgets/business_information_section.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
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

  Future<void> _getCurrentLocation(BuildContext context) async {
    try {
      // Request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Location permissions are permanently denied, enable in settings'),
          ),
        );
        return;
      }

      // Get position
      final Position position = await Geolocator.getCurrentPosition();

      // Get address from position
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address =
            '${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}';
        locationController.text = address;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
      print('Error getting location: $e');
    }
  }

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

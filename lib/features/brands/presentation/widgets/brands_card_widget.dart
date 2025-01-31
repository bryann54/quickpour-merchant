import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:quickpourmerchant/features/brands/data/models/brands_model.dart';
import 'package:quickpourmerchant/features/brands/presentation/pages/brand_details_screen.dart';

class BrandCardWidget extends StatelessWidget {
  final BrandModel brand;
  final bool isVerified;

  const BrandCardWidget({
    super.key,
    required this.brand,
    this.isVerified = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _navigateToBrandDetails(context),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            // Background Image
            Hero(
              tag: 'brand-image-${brand.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: brand.logoUrl,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator.adaptive(),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            // Brand Details
            Positioned(
              bottom: 1,
              left: 16,
              right: 16,
              child: Hero(
                tag: 'brand-name-${brand.id}',
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    brand.country,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            // Verified Badge
            if (isVerified)
              Positioned(
                top: 16,
                right: 16,
                child: Icon(
                  Icons.verified,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _navigateToBrandDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BrandDetailsScreen(brand: brand),
      ),
    );
  }
}

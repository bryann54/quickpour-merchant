import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quickpourmerchant/core/utils/date_formatter.dart';
import 'package:quickpourmerchant/features/promotions/data/models/promotion_model.dart';
import 'package:quickpourmerchant/features/promotions/presentation/pages/promo_details_screen.dart';

class PromotionCard extends StatelessWidget {
  final MerchantPromotionModel promotion;
  final VoidCallback? onEditPressed;
  final List<AdminProductModel>? prefetchedProducts;

  const PromotionCard({
    super.key,
    required this.promotion,
    this.onEditPressed,
    this.prefetchedProducts,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () => _handleCardTap(context),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey.shade900 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isDarkMode ? Colors.black54 : Colors.grey.shade200,
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Promotion Image with Status Badge
            Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: promotion.imageUrl?.isNotEmpty == true
                      ? promotion.imageUrl!
                      : '',
                  placeholder: (context, url) => Container(
                    width: double.infinity,
                    height: 160,
                    color: isDarkMode
                        ? Colors.grey.shade800
                        : Colors.grey.shade100,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: double.infinity,
                    height: 160,
                    color: isDarkMode
                        ? Colors.grey.shade800
                        : Colors.grey.shade100,
                    child: const Icon(Icons.image_not_supported),
                  ),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 160,
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: _statusBadge(promotion.isActive),
                ),
              ],
            ),

            // Promotion Details
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Campaign Title
                  Text(
                    promotion.campaignTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 6),

                  // Promotion Type and Target
                  Text(
                    '${promotion.promotionType} | ${getTargetLabel(promotion)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 6),

                  // Discount and Duration
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _discountBadge(promotion.discountPercentage),
                      _durationBadge(promotion.startDate, promotion.endDate),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Handles tap on the card and navigates to promo details
  Future<void> _handleCardTap(BuildContext context) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      if (context.mounted) {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PromoDetailsScreen(
              promotion: promotion,
              prefetchedProducts: prefetchedProducts,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to load promotion details: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  /// Status Badge (Active or Inactive)
  Widget _statusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: const TextStyle(
            color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  /// Discount Badge
  Widget _discountBadge(double discountPercentage) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.shade600,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(FontAwesomeIcons.tag, color: Colors.white, size: 12),
          const SizedBox(width: 4),
          Text(
            '${discountPercentage.toStringAsFixed(0)}% OFF',
            style: const TextStyle(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  /// Duration Badge
  Widget _durationBadge(DateTime start, DateTime end) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.shade600,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${formatDate(start)} - ${formatDate(end)}',
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }


}

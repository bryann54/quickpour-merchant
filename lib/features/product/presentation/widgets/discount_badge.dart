// lib/features/product/presentation/widgets/discount_badge.dart

import 'package:flutter/material.dart';

class DiscountBadge extends StatelessWidget {
  final double originalPrice;
  final double discountPrice;

  const DiscountBadge({
    Key? key,
    required this.originalPrice,
    required this.discountPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (discountPrice <= 0) return const SizedBox.shrink();

    final discountPercentage =
        (100 - ((discountPrice / originalPrice) * 100)).round();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$discountPercentage% OFF',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SummaryShimmer extends StatelessWidget {
  const SummaryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    final highlightColor = Theme.of(context).colorScheme.surface;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _box(height: 180, radius: 12),
            const SizedBox(height: 12),
            _box(height: 180, radius: 12),
          ],
        ),
      ),
    );
  }

  Widget _box({required double height, double radius = 4}) => Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
}

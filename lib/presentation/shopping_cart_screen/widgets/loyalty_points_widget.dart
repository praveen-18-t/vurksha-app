import 'package:flutter/material.dart';

/// Loyalty Points Widget
class LoyaltyPointsWidget extends StatelessWidget {
  final int availablePoints;
  final int pointsToUse;
  final Function(int)? onPointsChanged;
  final bool canUsePoints;

  const LoyaltyPointsWidget({
    super.key,
    required this.availablePoints,
    this.pointsToUse = 0,
    this.onPointsChanged,
    this.canUsePoints = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Loyalty Points',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text('Available Points: $availablePoints'),
          Text('Use points to get discounts on your order'),
        ],
      ),
    );
  }
}

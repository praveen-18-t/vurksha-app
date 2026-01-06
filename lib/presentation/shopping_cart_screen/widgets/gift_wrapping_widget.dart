import 'package:flutter/material.dart';

/// Gift Wrapping Widget
class GiftWrappingWidget extends StatelessWidget {
  final bool isAdded;
  final double charge;
  final VoidCallback? onToggle;

  const GiftWrappingWidget({
    super.key,
    required this.isAdded,
    this.charge = 25.0,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gift Wrapping',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text('Premium Gift Wrapping'),
          Text('Charge: ₹$charge'),
          Text('Make your gift extra special with eco-friendly wrapping'),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Save for Later Widget
class SaveForLaterWidget extends StatelessWidget {
  final List<Map<String, dynamic>> savedItems;
  final Function(String)? onRemoveItem;
  final Function(String)? onMoveToCart;

  const SaveForLaterWidget({
    super.key,
    this.savedItems = const [],
    this.onRemoveItem,
    this.onMoveToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Saved for Later',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (savedItems.isEmpty)
            const Text('No items saved for later')
          else
            Text('You have ${savedItems.length} items saved'),
        ],
      ),
    );
  }
}

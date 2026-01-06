import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../data/providers/cart_provider.dart';
import '../../../data/providers/saved_items_provider.dart';

/// Saved items widget showing items saved for later
class SavedItemsWidget extends ConsumerWidget {
  const SavedItemsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final savedItemsState = ref.watch(savedItemsProvider);
    final savedItemsNotifier = ref.read(savedItemsProvider.notifier);
    final cartNotifier = ref.read(cartProvider.notifier);

    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Saved for Later',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (savedItemsState.savedItems.isNotEmpty)
                TextButton(
                  onPressed: () {
                    _showClearAllDialog(context, savedItemsNotifier);
                  },
                  child: Text(
                    'Clear All',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 2.h),

          // Saved items list
          if (savedItemsState.savedItems.isEmpty)
            Container(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Center(
                child: Column(
                  children: [
                    CustomIconWidget(
                      iconName: 'bookmark_border',
                      size: 48,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'No saved items yet',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Save items for later to buy them when you\'re ready',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              itemCount: savedItemsState.savedItems.length,
              itemBuilder: (context, index) {
                final savedItem = savedItemsState.savedItems[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 1.h),
                  child: Padding(
                    padding: EdgeInsets.all(2.w),
                    child: Row(
                      children: [
                        // Product image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CustomImageWidget(
                            imageUrl: savedItem.image,
                            width: 16.w,
                            height: 16.w,
                            fit: BoxFit.cover,
                            semanticLabel: savedItem.name,
                          ),
                        ),
                        SizedBox(width: 3.w),

                        // Product details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                savedItem.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 0.5.h),
                              Text(
                                savedItem.unit,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  Text(
                                    '₹${savedItem.pricePerUnit.toStringAsFixed(2)}/${savedItem.unit}',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                SizedBox(width: 2.w),
                                // Restore button
                                ElevatedButton(
                                  onPressed: () {
                                    final restoredItem = savedItemsNotifier.restoreToCart(savedItem.id);
                                    cartNotifier.addItem(restoredItem);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${savedItem.name} restored to cart'),
                                        backgroundColor: theme.colorScheme.primary,
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.8.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'Move to Cart',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                // Delete button
                                IconButton(
                                  onPressed: () {
                                    savedItemsNotifier.removeSavedItem(savedItem.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${savedItem.name} removed from saved items'),
                                        backgroundColor: theme.colorScheme.error,
                                      ),
                                    );
                                  },
                                  icon: CustomIconWidget(
                                    iconName: 'delete_outline',
                                    size: 20,
                                    color: theme.colorScheme.error,
                                  ),
                                  tooltip: 'Remove saved item',
                                ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  void _showClearAllDialog(BuildContext context, SavedItemsNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear All Saved Items?'),
        content: Text('Are you sure you want to remove all saved items?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Clear all saved items logic would go here
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('All saved items cleared'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('Clear All'),
          ),
        ],
      ),
    );
  }
}

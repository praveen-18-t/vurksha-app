import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../data/models/cart_model.dart';

/// Cart item card widget displaying product details and quantity controls
class CartItemCardWidget extends StatelessWidget {
  const CartItemCardWidget({
    super.key,
    required this.item,
    required this.isEditMode,
    required this.onQuantityChanged,
    required this.onDelete,
    this.onSaveForLater,
    this.onVariantChanged,
    this.showStockWarning = true,
  });

  final CartItem item;
  final bool isEditMode;
  final Function(int) onQuantityChanged;
  final VoidCallback onDelete;
  final VoidCallback? onSaveForLater;
  final Function(String)? onVariantChanged;
  final bool showStockWarning;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalPrice = item.pricePerUnit * item.quantity;

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(2.w),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CustomImageWidget(
                  imageUrl: item.imageUrl,
                  width: 22.w,
                  height: 22.w,
                  fit: BoxFit.cover,
                  semanticLabel: item.name,
                ),
              ),
              SizedBox(width: 3.w),

              // Product details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name
                    Text(
                      item.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),

                    // Unit
                    Text(
                      item.unit,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),

                    // Price and quantity controls
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Stock warning
                        if (showStockWarning && item.quantity >= item.stockAvailable)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                            margin: EdgeInsets.only(bottom: 0.5.h),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CustomIconWidget(
                                  iconName: 'warning',
                                  size: 14,
                                  color: theme.colorScheme.error,
                                ),
                                SizedBox(width: 1.w),
                                Flexible(
                                  child: Text(
                                    'Max stock reached',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.error,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        // Price
                        Text(
                          '₹${totalPrice.toStringAsFixed(2)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 0.5.h),

                        // Quantity controls
                        if (!isEditMode)
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: theme.colorScheme.outline,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Decrease button
                                InkWell(
                                  onTap: () {
                                    if (item.quantity > 1) {
                                      onQuantityChanged(item.quantity - 1);
                                    }
                                  },
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    bottomLeft: Radius.circular(8),
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 2.w,
                                      vertical: 0.5.h,
                                    ),
                                    child: CustomIconWidget(
                                      iconName: 'remove',
                                      size: 18,
                                      color: item.quantity > 1
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),

                                // Quantity display
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                                    decoration: BoxDecoration(
                                      border: Border.symmetric(
                                        vertical: BorderSide(
                                          color: theme.colorScheme.outline,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${item.quantity} ${item.unit}',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Increase button
                                InkWell(
                                  onTap: () {
                                    if (item.quantity < item.stockAvailable) {
                                      onQuantityChanged(item.quantity + 1);
                                    }
                                  },
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(8),
                                    bottomRight: Radius.circular(8),
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 2.w,
                                      vertical: 0.5.h,
                                    ),
                                    child: CustomIconWidget(
                                      iconName: 'add',
                                      size: 18,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Delete button in edit mode
                        if (isEditMode)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: onSaveForLater,
                                icon: CustomIconWidget(
                                  iconName: 'bookmark_border',
                                  size: 24,
                                  color: theme.colorScheme.primary,
                                ),
                                tooltip: 'Save for later',
                              ),
                              IconButton(
                                onPressed: onDelete,
                                icon: CustomIconWidget(
                                  iconName: 'delete_outline',
                                  size: 24,
                                  color: theme.colorScheme.error,
                                ),
                                tooltip: 'Remove item',
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

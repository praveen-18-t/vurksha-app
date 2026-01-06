import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Stock availability indicator widget
class StockAvailabilityWidget extends StatelessWidget {
  final int stockCount;
  final bool inStock;

  const StockAvailabilityWidget({
    super.key,
    required this.stockCount,
    required this.inStock,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLowStock = stockCount <= 5 && stockCount > 0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: inStock
              ? (isLowStock
                    ? Colors.orange.withValues(alpha: 0.1)
                    : theme.colorScheme.primary.withValues(alpha: 0.1))
              : theme.colorScheme.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(2.h),
          border: Border.all(
            color: inStock
                ? (isLowStock ? Colors.orange : theme.colorScheme.primary)
                : theme.colorScheme.error,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: inStock ? 'check_circle' : 'cancel',
              color: inStock
                  ? (isLowStock ? Colors.orange : theme.colorScheme.primary)
                  : theme.colorScheme.error,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                inStock
                    ? (isLowStock
                          ? 'Only $stockCount left in stock - Order soon!'
                          : 'In Stock')
                    : 'Out of Stock',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: inStock
                      ? (isLowStock ? Colors.orange : theme.colorScheme.primary)
                      : theme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

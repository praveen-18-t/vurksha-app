import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../data/models/order_model.dart';

class OrderItemsWidget extends StatelessWidget {
  final List<OrderItem> items;

  const OrderItemsWidget({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Items',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 1.5.h),
          ...items.map((item) => _OrderItemRow(item: item)),
        ],
      ),
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  final OrderItem item;

  const _OrderItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final name = item.name;
    final qty = item.quantity;
    final weight = item.weight;
    final price = '₹${item.price.toStringAsFixed(0)}';
    final imageUrl = item.imageUrl;

    return Padding(
      padding: EdgeInsets.only(bottom: 1.2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 18.w,
              height: 18.w,
              color: theme.colorScheme.surfaceContainerHighest,
              child: imageUrl.isEmpty
                  ? Icon(Icons.image, color: theme.hintColor)
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.broken_image, color: theme.hintColor);
                      },
                    ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Qty: $qty${weight.isEmpty ? '' : '    $weight'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 2.w),
          Text(
            '₹$price',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

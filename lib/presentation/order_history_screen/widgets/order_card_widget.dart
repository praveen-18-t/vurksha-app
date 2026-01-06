import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Order Card Widget - Display individual order information
class OrderCardWidget extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback onTap;

  const OrderCardWidget({
    super.key,
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = order['status'] as String;
    final statusColor = _getStatusColor(status, theme);
    final statusText = _getStatusText(status);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(2.h),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(2.h),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order['id']}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          order['date'] as String,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(1.h),
                      ),
                      child: Text(
                        statusText,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 2.h),
                
                // Order Details
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'inventory_2',
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 4.w,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      '${order['items']} items',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    CustomIconWidget(
                      iconName: 'location_on',
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 4.w,
                    ),
                    SizedBox(width: 1.w),
                    Expanded(
                      child: Text(
                        order['deliveryAddress'] as String,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 1.5.h),
                
                // Estimated Delivery (for active orders)
                if (status != 'delivered' && status != 'cancelled')
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'schedule',
                        color: theme.colorScheme.primary,
                        size: 4.w,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        'Est. delivery: ${order['estimatedDelivery']}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                
                SizedBox(height: 2.h),
                
                // Footer with total and arrow
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: ₹${order['total'].toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status, ThemeData theme) {
    switch (status) {
      case 'delivered':
        return Colors.green;
      case 'in_transit':
        return Colors.blue;
      case 'processing':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'delivered':
        return 'Delivered';
      case 'in_transit':
        return 'In Transit';
      case 'processing':
        return 'Processing';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }
}

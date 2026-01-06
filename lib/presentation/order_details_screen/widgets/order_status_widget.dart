import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Order Status Widget - Display order status and timeline
import 'package:vurksha_farm_delivery/data/models/order_model.dart';

class OrderStatusWidget extends StatelessWidget {
  final Order order;

  const OrderStatusWidget({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = order.status;
    final statusColor = _getStatusColor(status, theme);
    final statusText = _getStatusText(status);

    return Container(
      margin: EdgeInsets.all(4.w),
      padding: EdgeInsets.all(4.w),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Header
          Row(
            children: [
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: CustomIconWidget(
                  iconName: _getStatusIcon(status),
                  color: statusColor,
                  size: 4.w,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusText,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'Order placed on ${order.date.day}/${order.date.month}/${order.date.year}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 3.h),
          
          // Timeline
          _buildTimeline(context, theme, status),
          
          SizedBox(height: 2.h),
          
          // Delivery Address
          if (status != 'cancelled')
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delivery Address',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 1.h),
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'location_on',
                      color: theme.colorScheme.primary,
                      size: 4.w,
                    ),
                    SizedBox(width: 1.w),
                    Expanded(
                      child: Text(
                        order.deliveryAddress,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
                if (status != 'delivered') ...[
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'schedule',
                        color: theme.colorScheme.primary,
                        size: 4.w,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        'Est. delivery: ${order.estimatedDelivery.day}/${order.estimatedDelivery.month}/${order.estimatedDelivery.year}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context, ThemeData theme, String currentStatus) {
    final timelineSteps = [
      {'status': 'processing', 'title': 'Order Confirmed', 'completed': true},
      {'status': 'in_transit', 'title': 'Out for Delivery', 'completed': currentStatus == 'in_transit' || currentStatus == 'delivered'},
      {'status': 'delivered', 'title': 'Delivered', 'completed': currentStatus == 'delivered'},
    ];

    if (currentStatus == 'cancelled') {
      return Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.cancel,
                color: Colors.red,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Order Cancelled',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      children: timelineSteps.asMap().entries.map((entry) {
        final step = entry.value;
        final isLast = entry.key == timelineSteps.length - 1;
        final isCompleted = step['completed'] as bool;
        final isActive = step['status'] == currentStatus;

        return Column(
          children: [
            Row(
              children: [
                Container(
                  width: 6.w,
                  height: 6.w,
                  decoration: BoxDecoration(
                    color: isCompleted 
                        ? theme.colorScheme.primary 
                        : isActive 
                            ? theme.colorScheme.primary.withValues(alpha: 0.3)
                            : theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: isActive 
                        ? Border.all(color: theme.colorScheme.primary, width: 2)
                        : null,
                  ),
                  child: isCompleted
                      ? Icon(
                          Icons.check,
                          color: theme.colorScheme.onPrimary,
                          size: 3.w,
                        )
                      : null,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step['title'] as String,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                          color: isCompleted || isActive
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!isLast)
              Container(
                margin: EdgeInsets.only(left: 3.w),
                height: 3.h,
                width: 2,
                color: isCompleted
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.2),
              ),
          ],
        );
      }).toList(),
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
        return 'Delivered Successfully';
      case 'in_transit':
        return 'Out for Delivery';
      case 'processing':
        return 'Order Processing';
      case 'cancelled':
        return 'Order Cancelled';
      default:
        return 'Unknown Status';
    }
  }

  String _getStatusIcon(String status) {
    switch (status) {
      case 'delivered':
        return 'check_circle';
      case 'in_transit':
        return 'local_shipping';
      case 'processing':
        return 'pending';
      case 'cancelled':
        return 'cancel';
      default:
        return 'help';
    }
  }
}

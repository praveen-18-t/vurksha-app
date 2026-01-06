import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:vurksha_farm_delivery/data/models/order_model.dart';
import 'package:vurksha_farm_delivery/widgets/custom_icon_widget.dart';

class ShippingDetailsWidget extends StatelessWidget {
  final Order order;

  const ShippingDetailsWidget({super.key, required this.order});

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
            'Shipping Details',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 1.5.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: 'location_on',
                color: theme.colorScheme.primary,
                size: 4.w,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  order.deliveryAddress,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: 'schedule',
                color: theme.colorScheme.primary,
                size: 4.w,
              ),
              SizedBox(width: 2.w),
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
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Order summary widget showing pricing breakdown
class OrderSummaryWidget extends StatelessWidget {
  const OrderSummaryWidget({
    super.key,
    required this.subtotal,
    required this.deliveryCharge,
    required this.discount,
    required this.total,
    required this.freeDeliveryThreshold,
    this.minimumOrderAmount,
    this.appliedCoupon,
    required this.onTogglePromoCode,
    required this.showPromoCode,
    this.onApplyCoupon,
    this.estimatedDeliveryTime,
    this.deliveryAddress,
  });

  final double subtotal;
  final double deliveryCharge;
  final double discount;
  final double total;
  final double freeDeliveryThreshold;
  final double? minimumOrderAmount;
  final String? appliedCoupon;
  final VoidCallback onTogglePromoCode;
  final bool showPromoCode;
  final Function(String)? onApplyCoupon;
  final DateTime? estimatedDeliveryTime;
  final String? deliveryAddress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amountToFreeDelivery = freeDeliveryThreshold - subtotal;
    final isFreeDelivery = deliveryCharge == 0.0;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outline, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Free delivery message
          if (!isFreeDelivery && amountToFreeDelivery > 0)
            Container(
              padding: EdgeInsets.all(2.w),
              margin: EdgeInsets.only(bottom: 2.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'local_shipping',
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Add ₹${amountToFreeDelivery.toStringAsFixed(2)} more for FREE delivery',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Delivery time estimation
          if (estimatedDeliveryTime != null)
            Container(
              margin: EdgeInsets.only(bottom: 2.h),
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'schedule',
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        'Estimated Delivery',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    _formatDeliveryTime(estimatedDeliveryTime!),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (deliveryAddress != null) ...[
                    SizedBox(height: 0.5.h),
                    Text(
                      'To: $deliveryAddress',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          
          // Order summary title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order Summary',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: onTogglePromoCode,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: showPromoCode ? 'expand_less' : 'expand_more',
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          'Promo Code',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (appliedCoupon != null) ...[
                    SizedBox(width: 2.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomIconWidget(
                            iconName: 'local_offer',
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            appliedCoupon!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Promo code input
          if (showPromoCode)
            Container(
              margin: EdgeInsets.only(bottom: 2.h),
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border.all(color: theme.colorScheme.outline, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Enter promo code',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 1.h,
                        ),
                      ),
                      onSubmitted: (value) {
                        if (value.isNotEmpty && onApplyCoupon != null) {
                          onApplyCoupon!(value.trim());
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 2.w),
                  ElevatedButton(
                    onPressed: () {
                      // Apply coupon logic would be handled by parent
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Apply'),
                  ),
                ],
              ),
            ),
          SizedBox(height: 1.h),

          // Subtotal
          _buildSummaryRow(
            context,
            'Subtotal',
            '₹${subtotal.toStringAsFixed(2)}',
            theme,
          ),
          SizedBox(height: 1.h),

          // Delivery charge
          _buildSummaryRow(
            context,
            'Delivery Charge',
            isFreeDelivery ? 'FREE' : '₹${deliveryCharge.toStringAsFixed(2)}',
            theme,
            valueColor: isFreeDelivery ? theme.colorScheme.primary : null,
          ),
          SizedBox(height: 1.h),

          // Discount
          if (discount > 0) ...[
            _buildSummaryRow(
              context,
              'Discount',
              '-₹${discount.toStringAsFixed(2)}',
              theme,
              valueColor: theme.colorScheme.primary,
            ),
            SizedBox(height: 1.h),
          ],

          Divider(color: theme.colorScheme.outline, thickness: 1, height: 2.h),

          // Total
          _buildSummaryRow(
            context,
            'Total',
            '₹${total.toStringAsFixed(2)}',
            theme,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  /// Build summary row
  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value,
    ThemeData theme, {
    bool isTotal = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                )
              : theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
        ),
        Text(
          value,
          style: isTotal
              ? theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                )
              : theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                ),
        ),
      ],
    );
  }

  /// Format delivery time
  String _formatDeliveryTime(DateTime deliveryTime) {
    final now = DateTime.now();
    final difference = deliveryTime.difference(now);
    
    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        final hour = deliveryTime.hour;
        final minute = deliveryTime.minute.toString().padLeft(2, '0');
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        return 'Tomorrow, $displayHour:$minute $period';
      } else {
        final hour = deliveryTime.hour;
        final minute = deliveryTime.minute.toString().padLeft(2, '0');
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        return '${deliveryTime.day}/${deliveryTime.month}, $displayHour:$minute $period';
      }
    } else if (difference.inHours > 0) {
      return 'In ${difference.inHours} hour${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'In ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'ASAP';
    }
  }
}

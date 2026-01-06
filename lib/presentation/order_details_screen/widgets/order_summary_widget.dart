import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:vurksha_farm_delivery/data/models/order_model.dart';

class OrderSummaryWidget extends StatelessWidget {
  final Order order;

  const OrderSummaryWidget({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final subTotal = order.subTotal;
    final deliveryFee = order.deliveryFee;
    final total = order.total;

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
            'Summary',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 1.5.h),
          _Row(label: 'Subtotal', value: _formatMoney(subTotal), theme: theme),
          SizedBox(height: 0.8.h),
          _Row(label: 'Delivery fee', value: _formatMoney(deliveryFee), theme: theme),
          Divider(height: 3.h),
          _Row(
            label: 'Total',
            value: _formatMoney(total),
            theme: theme,
            bold: true,
            valueColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  
  String _formatMoney(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;
  final bool bold;
  final Color? valueColor;

  const _Row({
    required this.label,
    required this.value,
    required this.theme,
    this.bold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final style = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(
          value,
          style: style?.copyWith(color: valueColor),
        ),
      ],
    );
  }
}

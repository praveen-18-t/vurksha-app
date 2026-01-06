import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class OrderStatisticsWidget extends StatelessWidget {
  final int totalOrders;
  final double totalSpent;
  final double averageOrderValue;

  const OrderStatisticsWidget({
    super.key,
    required this.totalOrders,
    required this.totalSpent,
    required this.averageOrderValue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(1.5.h),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Statistics',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(context, Icons.shopping_bag, totalOrders.toString(), 'Total Orders'),
              _buildStatItem(context, Icons.monetization_on, '₹${totalSpent.toStringAsFixed(2)}', 'Total Spent'),
              _buildStatItem(context, Icons.receipt_long, '₹${averageOrderValue.toStringAsFixed(2)}', 'Avg. Order'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String value, String label) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, size: 6.w, color: theme.colorScheme.primary),
        SizedBox(height: 1.h),
        Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        SizedBox(height: 0.5.h),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

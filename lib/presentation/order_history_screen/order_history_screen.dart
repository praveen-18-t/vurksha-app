import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../widgets/custom_app_bar.dart';
import 'widgets/order_card_widget.dart';

/// Order History Screen - Display user's past orders
class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  // Mock order data
  final List<Map<String, dynamic>> _orders = const [
    {
      'id': 'ORD001',
      'date': '2024-12-20',
      'status': 'delivered',
      'total': 450.00,
      'items': 5,
      'deliveryAddress': '123 Main St, Pune, Maharashtra 411001',
      'estimatedDelivery': '2024-12-21 10:00 AM',
    },
    {
      'id': 'ORD002',
      'date': '2024-12-18',
      'status': 'in_transit',
      'total': 280.00,
      'items': 3,
      'deliveryAddress': '456 Oak Ave, Mumbai, Maharashtra 400001',
      'estimatedDelivery': '2024-12-22 2:00 PM',
    },
    {
      'id': 'ORD003',
      'date': '2024-12-15',
      'status': 'processing',
      'total': 320.00,
      'items': 4,
      'deliveryAddress': '789 Pine Rd, Delhi, Delhi 110001',
      'estimatedDelivery': '2024-12-23 11:00 AM',
    },
    {
      'id': 'ORD004',
      'date': '2024-12-10',
      'status': 'cancelled',
      'total': 180.00,
      'items': 2,
      'deliveryAddress': '321 Elm St, Bangalore, Karnataka 560001',
      'estimatedDelivery': '2024-12-12 3:00 PM',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        variant: AppBarVariant.standard,
        title: Text('Order History'),
        showBackButton: true,
      ),
      body: _orders.isEmpty
          ? _buildEmptyState(context, theme)
          : ListView.builder(
              padding: EdgeInsets.all(4.w),
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                final order = _orders[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 2.h),
                  child: OrderCardWidget(
                    order: order,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/order-details-screen',
                        arguments: order,
                      );
                    },
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 15.w,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          SizedBox(height: 2.h),
          Text(
            'No orders yet',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Start shopping to see your orders here',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ),
          SizedBox(height: 3.h),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/home-screen');
            },
            child: const Text('Start Shopping'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:vurksha_farm_delivery/data/models/order_model.dart';

import '../../widgets/custom_app_bar.dart';
import 'widgets/order_status_widget.dart';
import 'widgets/order_items_widget.dart';
import 'widgets/order_summary_widget.dart';
import 'widgets/shipping_details_widget.dart';
import 'widgets/payment_details_widget.dart';

/// Order Details Screen - Detailed view of a single order
class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Attempt to get order from arguments, otherwise use mock data
    final Order order = (ModalRoute.of(context)?.settings.arguments as Order?) ?? _getMockOrder();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        variant: AppBarVariant.standard,
        title: Text('Order #${order.id}'),
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Order Status
            OrderStatusWidget(order: order),
            
            // Order Items
            OrderItemsWidget(items: order.items),
            
            // Shipping Details
            ShippingDetailsWidget(order: order),

            // Payment Details
            PaymentDetailsWidget(order: order),

            // Order Summary
            OrderSummaryWidget(order: order),
            
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  Order _getMockOrder() {
    return Order(
      id: 'ORD001',
      date: DateTime(2024, 12, 20),
      status: 'delivered',
      total: 450.00,
      deliveryAddress: '123 Main St, Pune, Maharashtra 411001',
      estimatedDelivery: DateTime(2024, 12, 21, 10, 0),
      items: [
        OrderItem(
          name: 'Fresh Organic Tomatoes',
          quantity: 2,
          weight: '1kg',
          price: 80.00,
          imageUrl: 'https://images.unsplash.com/photo-1569209548020-2fb7c81253a8',
        ),
        OrderItem(
          name: 'Organic Spinach',
          quantity: 1,
          weight: '500g',
          price: 40.00,
          imageUrl: 'https://images.unsplash.com/photo-1576091160550-2173dba999ef',
        ),
        OrderItem(
          name: 'Fresh Carrots',
          quantity: 3,
          weight: '2kg',
          price: 120.00,
          imageUrl: 'https://images.unsplash.com/photo-1445282768815-7d6ebaa6c4a5',
        ),
        OrderItem(
          name: 'Organic Potatoes',
          quantity: 2,
          weight: '2kg',
          price: 60.00,
          imageUrl: 'https://images.unsplash.com/photo-1518977676601-b0366e1603b5',
        ),
        OrderItem(
          name: 'Fresh Onions',
          quantity: 1,
          weight: '1kg',
          price: 50.00,
          imageUrl: 'https://images.unsplash.com/photo-1592750475338-74b7b21085ab',
        ),
      ],
      deliveryFee: 40.00,
      subTotal: 410.00,
      paymentDetails: PaymentDetails(
        paymentMethod: 'Credit Card',
        transactionId: 'txn_1234567890',
      ),
    );
  }
}

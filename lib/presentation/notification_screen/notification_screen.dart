import 'package:flutter/material.dart';
import '../../data/models/notification_model.dart';
import '../../data/models/order_model.dart';
import '../order_details_screen/order_details_screen.dart';
import 'widgets/notification_list_widget.dart';
import 'widgets/notification_settings_widget.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<NotificationModel> _notifications = [];
  NotificationSettings _settings = NotificationSettings();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _notifications = _getMockNotifications();
      _settings = NotificationSettings(); // Load from storage in a real app
      _isLoading = false;
    });
  }

  void _onNotificationRead(String id) {
    setState(() {
      _notifications = _notifications.map((n) {
        if (n.id == id) {
          return n.copyWith(isRead: true);
        }
        return n;
      }).toList();
    });
  }

  void _onDeleteNotification(String id) {
    setState(() {
      _notifications.removeWhere((n) => n.id == id);
    });
  }

  void _onClearAll() {
    setState(() {
      _notifications.clear();
    });
  }

  void _onMarkAllAsRead() {
    setState(() {
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    });
  }

  void _onSettingsChanged(NotificationSettings newSettings) {
    setState(() {
      _settings = newSettings;
    });
    // In a real app, you would save settings to a persistent storage
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification settings saved')),
    );
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Mark the notification as read when tapped
    _onNotificationRead(notification.id);

    if (notification.data != null && notification.data!.containsKey('orderId')) {
      final orderId = notification.data!['orderId'] as String;

      // In a real app, you would fetch the full order details using the orderId.
      // For this demo, we'll find a mock order from a predefined list or create one.
      final Order mockOrder = _getMockOrderForId(orderId);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const OrderDetailsScreen(),
          settings: RouteSettings(
            arguments: mockOrder,
          ),
        ),
      );
    } else if (notification.data != null &&
        notification.data!.containsKey('promoCode')) {
      final promoCode = notification.data!['promoCode'] as String;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Promotional Offer'),
          content: Text('Use promo code: $promoCode'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      // Fallback for notifications without specific actions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tapped on: ${notification.title}')),
      );
    }
  }

  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Notifications'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: theme.colorScheme.primary,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          tabs: const [
            Tab(text: 'All Notifications'),
            Tab(text: 'Settings'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                NotificationListWidget(
                  notifications: _notifications,
                  onNotificationRead: _onNotificationRead,
                  onDeleteNotification: _onDeleteNotification,
                  onClearAll: _onClearAll,
                  onMarkAllAsRead: _onMarkAllAsRead,
                  onRefresh: _loadData,
                  onNotificationTapped: _handleNotificationTap,
                ),
                NotificationSettingsWidget(
                  settings: _settings,
                  onSettingsChanged: _onSettingsChanged,
                ),
              ],
            ),
    );
  }

    Order _getMockOrderForId(String orderId) {
    // This is a simplified mock. A real app would have a proper data source.
    return Order(
      id: orderId,
      date: DateTime.now().subtract(const Duration(days: 1)),
      items: [
        OrderItem(
          name: 'Organic Bananas',
          quantity: 1,
          weight: '1kg',
          price: 120.00,
          imageUrl: 'https://images.unsplash.com/photo-1592924357228-91a803c0f6c7',
        ),
      ],
      status: 'Delivered',
      deliveryAddress: '123, Green Valley, Nature City',
      estimatedDelivery: DateTime.now().subtract(const Duration(days: 1)),
      subTotal: 120.00,
      deliveryFee: 20.00,
      total: 140.00,
      paymentDetails: PaymentDetails(
        paymentMethod: 'Credit Card',
        transactionId: 'TXN123456789',
      ),
    );
  }

  List<NotificationModel> _getMockNotifications() {
    return [
      NotificationModel(
        id: '1',
        category: NotificationCategory.orderUpdates,
        type: NotificationType.orderDelivered,
        title: 'Order Delivered!',
        body: 'Your order #ORD_001 has been successfully delivered. Enjoy your fresh produce!',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        isRead: false,
        data: {'orderId': 'ORD_001'},
      ),
      NotificationModel(
        id: '2',
        category: NotificationCategory.promotionalOffers,
        type: NotificationType.discountsAndDeals,
        title: 'Weekend Special: 20% Off!',
        body: 'Get 20% off on all leafy greens this weekend. Use code: GREEN20.',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
        data: {'promoCode': 'GREEN20'},
      ),
      NotificationModel(
        id: '3',
        category: NotificationCategory.deliveryUpdates,
        type: NotificationType.outForDelivery,
        title: 'Out for Delivery',
        body: 'Your order #ORD_002 is out for delivery and will reach you soon.',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        isRead: true,
        data: {'orderId': 'ORD_002'},
      ),
      NotificationModel(
        id: '4',
        category: NotificationCategory.accountAlerts,
        type: NotificationType.passwordChanges,
        title: 'Password Changed',
        body: 'Your password was successfully changed. If you did not make this change, please contact support immediately.',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
      ),
      NotificationModel(
        id: '5',
        category: NotificationCategory.paymentNotifications,
        type: NotificationType.paymentSuccess,
        title: 'Payment Successful',
        body: 'Your payment of ₹499 for order #ORD_002 was successful.',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        isRead: true,
        data: {'orderId': 'ORD_002', 'amount': 499.00},
      ),
    ];
  }
}

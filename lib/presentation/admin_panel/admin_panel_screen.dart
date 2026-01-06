import 'package:flutter/material.dart';
import 'widgets/admin_navigation_drawer.dart';
import 'widgets/admin_dashboard_widget.dart';
import 'order_management/order_management_screen.dart';
import 'product_management/product_management_screen.dart';
import 'customer_management/customer_management_screen.dart';
import 'delivery_management/delivery_management_screen.dart';
import 'content_management/content_management_screen.dart';
import 'settings/settings_screen.dart';
import 'reports/reports_screen.dart';
import 'security/security_screen.dart';
import 'support/support_screen.dart';

/// Admin Panel - Main dashboard for farm-to-home delivery app management
class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const AdminDashboardWidget(),
    const OrderManagementScreen(),
    const ProductManagementScreen(),
    const CustomerManagementScreen(),
    const DeliveryManagementScreen(),
    const ContentManagementScreen(),
    const SettingsScreen(),
    const ReportsScreen(),
    const SecurityScreen(),
    const SupportScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Admin Panel'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => _showNotifications(context),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () => _showProfile(context),
          ),
        ],
      ),
      drawer: AdminNavigationDrawer(
        currentIndex: _currentIndex,
        onItemSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
          Navigator.pop(context);
        },
      ),
      body: _screens[_currentIndex],
    );
  }

  void _showNotifications(BuildContext context) {
    // Show admin notifications
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Admin notifications')),
    );
  }

  void _showProfile(BuildContext context) {
    // Show admin profile
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Admin Profile'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              child: Icon(Icons.admin_panel_settings, size: 40),
            ),
            SizedBox(height: 16),
            Text('Admin User'),
            Text('admin@vurksha.com'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

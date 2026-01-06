import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Profile Menu Widget - Settings and options menu
class ProfileMenuWidget extends StatelessWidget {
  final Map<String, dynamic> userData;
  final Function(Map<String, dynamic>) onUserDataUpdated;

  const ProfileMenuWidget({
    super.key,
    required this.userData,
    required this.onUserDataUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final menuItems = [
      {
        'icon': 'shopping_bag',
        'title': 'Order History',
        'subtitle': 'View your past orders',
        'route': AppRoutes.orderHistory,
        'color': theme.colorScheme.primary,
      },
      {
        'icon': 'location_on',
        'title': 'Delivery Addresses',
        'subtitle': 'Manage your addresses',
        'route': AppRoutes.deliveryAddresses,
        'color': theme.colorScheme.secondary,
      },
      {
        'icon': 'payment',
        'title': 'Payment Methods',
        'subtitle': 'Manage payment options',
        'route': AppRoutes.settings,
        'color': theme.colorScheme.tertiary,
      },
      {
        'icon': 'notifications',
        'title': 'Notifications',
        'subtitle': 'Manage notifications',
        'route': AppRoutes.notifications,
        'color': Colors.orange,
      },
      {
        'icon': 'help',
        'title': 'Help & Support',
        'subtitle': 'Get help and support',
        'route': AppRoutes.settings,
        'color': Colors.blue,
      },
      {
        'icon': 'settings',
        'title': 'Settings',
        'subtitle': 'App settings and preferences',
        'route': AppRoutes.settings,
        'color': Colors.grey,
      },
      {
        'icon': 'logout',
        'title': 'Logout',
        'subtitle': 'Sign out of your account',
        'route': '/logout',
        'color': Colors.red,
      },
    ];

    return Container(
      margin: EdgeInsets.all(4.w),
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
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: menuItems.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
        ),
        itemBuilder: (context, index) {
          final item = menuItems[index];
          final isLogout = item['route'] == '/logout';
          
          return ListTile(
            leading: Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: (item['color'] as Color).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2.h),
              ),
              child: CustomIconWidget(
                iconName: item['icon'] as String,
                color: item['color'] as Color,
                size: 5.w,
              ),
            ),
            title: Text(
              item['title'] as String,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: isLogout 
                    ? theme.colorScheme.error 
                    : theme.colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              item['subtitle'] as String,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            onTap: () {
              if (isLogout) {
                _showLogoutDialog(context);
              } else if (item.containsKey('route')) {
                Navigator.pushNamed(context, item['route'] as String);
              }
            },
          );
        },
      ),
    );
  }


  void _showLogoutDialog(BuildContext context) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Logout',
          style: theme.textTheme.titleLarge,
        ),
        content: Text(
          'Are you sure you want to logout from your account?',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Clear user session data
              try {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                
                // In a real app, you would also:
                // - Sign out from Firebase
                // - Clear any cached user data
                // - Reset app state management
                
                if (context.mounted) {
                  Navigator.pushReplacementNamed(
                    context, 
                    '/phone-authentication-screen'
                  );
                }
              } catch (e) {
                // Handle error during logout
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error during logout'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

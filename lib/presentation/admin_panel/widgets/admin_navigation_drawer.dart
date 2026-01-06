import 'package:flutter/material.dart';

/// Admin Navigation Drawer - Side navigation for admin panel
class AdminNavigationDrawer extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemSelected;

  const AdminNavigationDrawer({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  final List<NavigationItem> _navigationItems = const [
    NavigationItem(
      icon: Icons.dashboard,
      title: 'Dashboard',
      subtitle: 'Overview & Analytics',
    ),
    NavigationItem(
      icon: Icons.shopping_cart,
      title: 'Orders',
      subtitle: 'Order Management',
    ),
    NavigationItem(
      icon: Icons.inventory,
      title: 'Products',
      subtitle: 'Product Management',
    ),
    NavigationItem(
      icon: Icons.people,
      title: 'Customers',
      subtitle: 'Customer Management',
    ),
    NavigationItem(
      icon: Icons.local_shipping,
      title: 'Delivery',
      subtitle: 'Delivery Management',
    ),
    NavigationItem(
      icon: Icons.article,
      title: 'Content',
      subtitle: 'Content Management',
    ),
    NavigationItem(
      icon: Icons.settings,
      title: 'Settings',
      subtitle: 'Configuration',
    ),
    NavigationItem(
      icon: Icons.assessment,
      title: 'Reports',
      subtitle: 'Reports & Exports',
    ),
    NavigationItem(
      icon: Icons.security,
      title: 'Security',
      subtitle: 'Access Control',
    ),
    NavigationItem(
      icon: Icons.support_agent,
      title: 'Support',
      subtitle: 'Support Tools',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: Column(
        children: [
          // Header
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
            ),
            accountName: const Text('Admin User'),
            accountEmail: const Text('admin@vurksha.com'),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.admin_panel_settings, color: Colors.blue),
            ),
          ),
          
          // Navigation Items
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _navigationItems.length,
              itemBuilder: (context, index) {
                final item = _navigationItems[index];
                final isSelected = currentIndex == index;

                return ListTile(
                  leading: Icon(
                    item.icon,
                    color: isSelected ? theme.colorScheme.primary : null,
                  ),
                  title: Text(
                    item.title,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? theme.colorScheme.primary : null,
                    ),
                  ),
                  subtitle: Text(item.subtitle),
                  selected: isSelected,
                  selectedTileColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                  onTap: () => onItemSelected(index),
                );
              },
            ),
          ),
          
          // Footer
          Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              // Handle logout
            },
          ),
        ],
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String title;
  final String subtitle;

  const NavigationItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

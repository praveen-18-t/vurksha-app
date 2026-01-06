import 'package:flutter/material.dart';

import '../core/app_export.dart';

/// Navigation item variant for CustomBottomBar
enum BottomBarVariant {
  /// Standard bottom navigation with icons and labels
  standard,

  /// Compact bottom navigation with icons only
  compact,

  /// Bottom navigation with floating action button
  withFab,
}

/// A custom bottom navigation bar widget for farm-to-home delivery app
/// Implements thumb-reachable navigation optimized for one-handed mobile use
class CustomBottomBar extends StatelessWidget {
  /// Creates a custom bottom navigation bar
  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.variant = BottomBarVariant.standard,
    this.showLabels = true,
    this.elevation = 4.0,
  });

  /// Current selected index
  final int currentIndex;

  /// Callback when navigation item is tapped
  final ValueChanged<int> onTap;

  /// Visual variant of the bottom bar
  final BottomBarVariant variant;

  /// Whether to show labels below icons
  final bool showLabels;

  /// Elevation of the bottom bar
  final double elevation;

  /// Navigation items configuration based on Mobile Navigation Hierarchy
  static const List<_NavigationItem> _items = [
    _NavigationItem(
      icon: Icons.eco_outlined,
      activeIcon: Icons.eco,
      label: 'Home',
      route: AppRoutes.home,
    ),
    _NavigationItem(
      icon: Icons.grid_view_outlined,
      activeIcon: Icons.grid_view,
      label: 'Categories',
      route: AppRoutes.categoryListing,
    ),
    _NavigationItem(
      icon: Icons.shopping_bag_outlined,
      activeIcon: Icons.shopping_bag,
      label: 'Cart',
      route: AppRoutes.shoppingCart,
    ),
    _NavigationItem(
      icon: Icons.inventory_2_outlined,
      activeIcon: Icons.inventory_2,
      label: 'Orders',
      route: AppRoutes.orderHistory,
    ),
    _NavigationItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      label: 'Settings',
      route: AppRoutes.settings,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    switch (variant) {
      case BottomBarVariant.compact:
        return _buildCompactBar(context, theme, colorScheme);
      case BottomBarVariant.withFab:
        return _buildBarWithFab(context, theme, colorScheme);
      case BottomBarVariant.standard:
        return _buildStandardBar(context, theme, colorScheme);
    }
  }

  /// Builds standard bottom navigation bar
  Widget _buildStandardBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow,
            blurRadius: elevation * 2,
            offset: Offset(0, -elevation / 2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final isSelected = currentIndex == index;

              return Expanded(
                child: InkWell(
                  onTap: () => _handleTap(context, index, item.route),
                  splashColor: colorScheme.primary.withValues(alpha: 0.1),
                  highlightColor: colorScheme.primary.withValues(alpha: 0.05),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? item.activeIcon : item.icon,
                        color: isSelected
                            ? colorScheme.primary
                            : theme.textTheme.bodyMedium?.color?.withValues(
                                alpha: 0.6,
                              ),
                        size: 24,
                      ),
                      if (showLabels) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isSelected
                                ? colorScheme.primary
                                : theme.textTheme.bodyMedium?.color?.withValues(
                                    alpha: 0.6,
                                  ),
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  /// Builds compact bottom navigation bar (icons only)
  Widget _buildCompactBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow,
            blurRadius: elevation * 2,
            offset: Offset(0, -elevation / 2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final isSelected = currentIndex == index;

              return Expanded(
                child: InkWell(
                  onTap: () => _handleTap(context, index, item.route),
                  splashColor: colorScheme.primary.withValues(alpha: 0.1),
                  highlightColor: colorScheme.primary.withValues(alpha: 0.05),
                  child: Center(
                    child: Icon(
                      isSelected ? item.activeIcon : item.icon,
                      color: isSelected
                          ? colorScheme.primary
                          : theme.textTheme.bodyMedium?.color?.withValues(
                              alpha: 0.6,
                            ),
                      size: 24,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  /// Builds bottom navigation bar with floating action button
  Widget _buildBarWithFab(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    // Split items around the FAB (cart in center)
    final leftItems = _items.sublist(0, 2);
    final rightItems = _items.sublist(3);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow,
            blurRadius: elevation * 2,
            offset: Offset(0, -elevation / 2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Left items
              ...leftItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = currentIndex == index;

                return Expanded(
                  child: InkWell(
                    onTap: () => _handleTap(context, index, item.route),
                    child: _buildNavItem(
                      context,
                      theme,
                      colorScheme,
                      item,
                      isSelected,
                    ),
                  ),
                );
              }),
              // FAB placeholder space
              const SizedBox(width: 72),
              // Right items
              ...rightItems.asMap().entries.map((entry) {
                final index = entry.key + 3; // Offset by 3 (left items + cart)
                final item = entry.value;
                final isSelected = currentIndex == index;

                return Expanded(
                  child: InkWell(
                    onTap: () => _handleTap(context, index, item.route),
                    child: _buildNavItem(
                      context,
                      theme,
                      colorScheme,
                      item,
                      isSelected,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds individual navigation item
  Widget _buildNavItem(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    _NavigationItem item,
    bool isSelected,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isSelected ? item.activeIcon : item.icon,
          color: isSelected
              ? colorScheme.primary
              : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
          size: 24,
        ),
        if (showLabels) ...[
          const SizedBox(height: 4),
          Text(
            item.label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isSelected
                  ? colorScheme.primary
                  : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  /// Handles navigation tap with smooth transition
  void _handleTap(BuildContext context, int index, String route) {
    onTap(index);

    // Navigate to the corresponding route if different from current
    if (index != currentIndex) {
      Navigator.pushNamed(context, route);
    }
  }
}

/// Internal class to hold navigation item data
class _NavigationItem {
  const _NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
}

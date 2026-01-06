import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_export.dart';

/// App bar variant for CustomAppBar
enum AppBarVariant {
  /// Standard app bar with title and actions
  standard,

  /// App bar with search functionality
  search,

  /// App bar with back button and title
  detail,

  /// Transparent app bar for overlays
  transparent,

  /// App bar with large title (iOS style)
  large,
}

/// A custom app bar widget for farm-to-home delivery app
/// Implements clean, minimal design with organic aesthetic
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Creates a custom app bar
  const CustomAppBar({
    super.key,
    this.title,
    this.variant = AppBarVariant.standard,
    this.leading,
    this.actions,
    this.onSearchChanged,
    this.searchHint = 'Search fresh products...',
    this.showBackButton = false,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.centerTitle = false,
  });

  /// Title text or widget
  final Widget? title;

  /// Visual variant of the app bar
  final AppBarVariant variant;

  /// Leading widget (typically back button or menu)
  final Widget? leading;

  /// Action widgets on the right side
  final List<Widget>? actions;

  /// Callback for search text changes
  final ValueChanged<String>? onSearchChanged;

  /// Search field hint text
  final String searchHint;

  /// Whether to show back button
  final bool showBackButton;

  /// Background color override
  final Color? backgroundColor;

  /// Foreground color override
  final Color? foregroundColor;

  /// Elevation of the app bar
  final double elevation;

  /// Whether to center the title
  final bool centerTitle;

  @override
  Size get preferredSize {
    switch (variant) {
      case AppBarVariant.large:
        return const Size.fromHeight(96);
      case AppBarVariant.search:
        return const Size.fromHeight(64);
      default:
        return const Size.fromHeight(56);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    switch (variant) {
      case AppBarVariant.search:
        return _buildSearchBar(context, theme, colorScheme);
      case AppBarVariant.detail:
        return _buildDetailBar(context, theme, colorScheme);
      case AppBarVariant.transparent:
        return _buildTransparentBar(context, theme, colorScheme);
      case AppBarVariant.large:
        return _buildLargeBar(context, theme, colorScheme);
      case AppBarVariant.standard:
        return _buildStandardBar(context, theme, colorScheme);
    }
  }

  /// Builds standard app bar
  Widget _buildStandardBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return AppBar(
      backgroundColor: backgroundColor ?? colorScheme.surface,
      foregroundColor: foregroundColor ?? colorScheme.onSurface,
      elevation: elevation,
      centerTitle: centerTitle,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
      ),
      leading:
          leading ??
          (showBackButton
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Back',
                )
              : null),
      title: title,
      actions:
          actions ??
          [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // Navigate to search or show search delegate
              },
              tooltip: 'Search',
            ),
            IconButton(
              icon: const Icon(Icons.person_outline),
              onPressed: () {
                // Navigate to profile screen
                Navigator.pushNamed(context, AppRoutes.profile);
              },
              tooltip: 'Profile',
            ),
          ],
    );
  }

  /// Builds search app bar with input field
  Widget _buildSearchBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return AppBar(
      backgroundColor: backgroundColor ?? colorScheme.surface,
      foregroundColor: foregroundColor ?? colorScheme.onSurface,
      elevation: elevation,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
      ),
      leading:
          leading ??
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Back',
          ),
      title: TextField(
        onChanged: onSearchChanged,
        autofocus: true,
        decoration: InputDecoration(
          hintText: searchHint,
          border: InputBorder.none,
          hintStyle: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        style: theme.textTheme.bodyLarge,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            // Clear search
          },
          tooltip: 'Clear',
        ),
      ],
    );
  }

  /// Builds detail page app bar with back button
  Widget _buildDetailBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return AppBar(
      backgroundColor: backgroundColor ?? colorScheme.surface,
      foregroundColor: foregroundColor ?? colorScheme.onSurface,
      elevation: elevation,
      centerTitle: centerTitle,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
      ),
      leading:
          leading ??
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Back',
          ),
      title: title,
      actions:
          actions ??
          [
            IconButton(
              icon: const Icon(Icons.favorite_border),
              onPressed: () {
                // Add to wishlist
              },
              tooltip: 'Add to wishlist',
            ),
            IconButton(
              icon: const Icon(Icons.share_outlined),
              onPressed: () {
                // Share product
              },
              tooltip: 'Share',
            ),
          ],
    );
  }

  /// Builds transparent app bar for overlays
  Widget _buildTransparentBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return AppBar(
      backgroundColor: Colors.transparent,
      foregroundColor: foregroundColor ?? Colors.white,
      elevation: 0,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      leading:
          leading ??
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'Back',
              color: Colors.white,
            ),
          ),
      actions: actions?.map((action) {
        return Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: action,
        );
      }).toList(),
    );
  }

  /// Builds large title app bar (iOS style)
  Widget _buildLargeBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return PreferredSize(
      preferredSize: preferredSize,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? colorScheme.surface,
          boxShadow: elevation > 0
              ? [
                  BoxShadow(
                    color: colorScheme.shadow,
                    blurRadius: elevation * 2,
                    offset: Offset(0, elevation / 2),
                  ),
                ]
              : null,
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar with actions
              SizedBox(
                height: 56,
                child: Row(
                  children: [
                    if (leading != null)
                      leading!
                    else if (showBackButton)
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.of(context).pop(),
                        tooltip: 'Back',
                      ),
                    const Spacer(),
                    if (actions != null) ...actions!,
                  ],
                ),
              ),
              // Large title
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: DefaultTextStyle(
                  style: theme.textTheme.headlineMedium!.copyWith(
                    color: foregroundColor ?? colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                  child: title ?? const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

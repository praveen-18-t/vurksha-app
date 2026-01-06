import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../notifications/notification_controller.dart';
import '../../../widgets/notification_badge.dart';

/// Production-ready Home app bar.
/// Layout (left → right): App logo, 2-line location, search, notifications (+ badge)
class HomeAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const HomeAppBar({
    super.key,
    required this.onSearchTap,
    required this.onNotificationTap,
    this.onLogoTap,
    this.onProfileTap,
    this.logoAssetPath = 'assets/images/vurksha_logo.png',
    this.deliverToLabel = 'Deliver to',
    this.location = 'Koramangala',
  });

  final VoidCallback onSearchTap;
  final VoidCallback onNotificationTap;
  final VoidCallback? onLogoTap;
  final VoidCallback? onProfileTap;

  final String logoAssetPath;

  final String deliverToLabel;
  final String location;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final notificationState = ref.watch(notificationControllerProvider);

    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: false,
      titleSpacing: 0,
      elevation: 0,
      backgroundColor: theme.colorScheme.surface,
      foregroundColor: theme.colorScheme.onSurface,
      flexibleSpace: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              // App logo (icon-based; swap with Image.asset when you add a real logo)
              _TapTarget(
                onTap: onLogoTap,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Image.asset(
                        logoAssetPath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.eco_rounded,
                            size: 20,
                            color: theme.colorScheme.primary,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Location (uses remaining width)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deliverToLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),

              // Search
              _TapTarget(
                onTap: onSearchTap,
                child: Icon(
                  Icons.search_rounded,
                  size: 24,
                  color: theme.colorScheme.onSurface,
                ),
              ),

              // Notifications (+ subtle badge)
              _TapTarget(
                onTap: onNotificationTap,
                child: NotificationBadge(
                  unreadCount: notificationState.unreadCount,
                  badgeType: notificationState.badgeType,
                  child: Icon(
                    Icons.notifications_none_rounded,
                    size: 24,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),

              // Profile button
              if (onProfileTap != null)
                _TapTarget(
                  onTap: onProfileTap,
                  child: Icon(
                    Icons.person_outline_rounded,
                    size: 24,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TapTarget extends StatelessWidget {
  const _TapTarget({
    required this.child,
    required this.onTap,
  });

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Center(child: child),
        ),
      ),
    );
  }
}

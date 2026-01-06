import 'package:flutter/material.dart';

import '../notifications/notification_repository.dart';

class NotificationBadge extends StatelessWidget {
  const NotificationBadge({
    super.key,
    required this.unreadCount,
    required this.badgeType,
    required this.child,
  });

  final int unreadCount;
  final NotificationBadgeType badgeType;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final show = unreadCount > 0;
    final theme = Theme.of(context);

    final resolved = badgeType == NotificationBadgeType.auto
        ? (unreadCount <= 3 ? NotificationBadgeType.dot : NotificationBadgeType.count)
        : badgeType;

    String? text;
    if (resolved == NotificationBadgeType.count) {
      text = unreadCount > 9 ? '9+' : unreadCount.toString();
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          right: -1,
          top: -1,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: !show
                ? const SizedBox.shrink()
                : _BadgePill(
                    key: ValueKey<String>('badge_${resolved}_$text'),
                    color: theme.colorScheme.error,
                    text: text,
                  ),
          ),
        ),
      ],
    );
  }
}

class _BadgePill extends StatelessWidget {
  const _BadgePill({
    super.key,
    required this.color,
    required this.text,
  });

  final Color color;
  final String? text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (text == null) {
      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      child: Center(
        child: Text(
          text!,
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
          maxLines: 1,
          overflow: TextOverflow.clip,
        ),
      ),
    );
  }
}

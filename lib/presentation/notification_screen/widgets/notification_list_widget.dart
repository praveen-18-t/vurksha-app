import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../data/models/notification_model.dart';
import '../../../widgets/custom_empty_widget.dart';
import 'notification_card_widget.dart';

class NotificationListWidget extends StatefulWidget {
  final List<NotificationModel> notifications;
  final Function(String) onNotificationRead;
  final Function(String) onDeleteNotification;
  final VoidCallback onClearAll;
  final VoidCallback onMarkAllAsRead;
  final Future<void> Function() onRefresh;
  final Function(NotificationModel) onNotificationTapped;

  const NotificationListWidget({
    super.key,
    required this.notifications,
    required this.onNotificationRead,
    required this.onDeleteNotification,
    required this.onClearAll,
    required this.onMarkAllAsRead,
    required this.onRefresh,
    required this.onNotificationTapped,
  });

  @override
  State<NotificationListWidget> createState() => _NotificationListWidgetState();
}

class _NotificationListWidgetState extends State<NotificationListWidget> {
  final Map<String, List<NotificationModel>> _groupedNotifications = {};

  @override
  void initState() {
    super.initState();
    _groupNotifications();
  }

  @override
  void didUpdateWidget(NotificationListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.notifications != oldWidget.notifications) {
      _groupNotifications();
    }
  }

  void _groupNotifications() {
    _groupedNotifications.clear();
    for (var notification in widget.notifications) {
      final groupKey = _getGroupKey(notification.createdAt);
      if (!_groupedNotifications.containsKey(groupKey)) {
        _groupedNotifications[groupKey] = [];
      }
      _groupedNotifications[groupKey]!.add(notification);
    }
  }

  String _getGroupKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date.isAfter(today)) {
      return 'Today';
    } else if (date.isAfter(yesterday)) {
      return 'Yesterday';
    } else {
      return 'Older';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.notifications.isEmpty) {
      return CustomEmptyWidget(
        icon: Icons.notifications_off_outlined,
        title: 'No Notifications Yet',
        subtitle: 'You\'ll see important updates and offers here.',
        onRefresh: widget.onRefresh,
      );
    }

    final groupKeys = _groupedNotifications.keys.toList();

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: Column(
        children: [
          _buildHeader(theme),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              itemCount: groupKeys.length,
              itemBuilder: (context, index) {
                final groupKey = groupKeys[index];
                final notificationsInGroup = _groupedNotifications[groupKey]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
                      child: Text(
                        groupKey,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    ...notificationsInGroup.map((notification) {
                      return NotificationCardWidget(
                        notification: notification,
                        onRead: () => widget.onNotificationRead(notification.id),
                        onDelete: () => widget.onDeleteNotification(notification.id),
                        onTap: () => widget.onNotificationTapped(notification),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: widget.onMarkAllAsRead,
            child: const Text('Mark All as Read'),
          ),
          SizedBox(width: 2.w),
          TextButton(
            onPressed: widget.onClearAll,
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}

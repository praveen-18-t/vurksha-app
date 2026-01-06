import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../data/models/notification_model.dart';

class NotificationCardWidget extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onRead;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const NotificationCardWidget({
    super.key,
    required this.notification,
    required this.onRead,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRead = notification.isRead;
    final bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    final cardContent = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildIcon(theme),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification.title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                notification.body,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isRead
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                      : theme.colorScheme.onSurface.withValues(alpha: 0.8),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 1.h),
              Text(
                _formatDate(notification.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 2.w),
        _buildActionMenu(context, theme),
      ],
    );

    return InkWell(
      onTap: () {
        onTap();
        if (!isRead) {
          onRead();
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 1.5.h),
        child: isIOS
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: (isRead
                              ? theme.colorScheme.surface
                              : theme.colorScheme.primary)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: (isRead
                                ? theme.dividerColor
                                : theme.colorScheme.primary)
                            .withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: cardContent,
                  ),
                ),
              )
            : Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: isRead
                      ? theme.colorScheme.surface.withValues(alpha: 0.5)
                      : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isRead
                        ? theme.dividerColor.withValues(alpha: 0.2)
                        : theme.colorScheme.primary.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: cardContent,
              ),
      ),
    );
  }

  Widget _buildIcon(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: notification.iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        notification.icon,
        color: notification.iconColor,
        size: 5.w,
      ),
    );
  }

  Widget _buildActionMenu(BuildContext context, ThemeData theme) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'read') {
          onRead();
        } else if (value == 'delete') {
          onDelete();
        }
      },
      itemBuilder: (context) => [
        if (!notification.isRead)
          const PopupMenuItem(
            value: 'read',
            child: Text('Mark as Read'),
          ),
        const PopupMenuItem(
          value: 'delete',
          child: Text('Delete'),
        ),
      ],
      child: Icon(
        Icons.more_vert,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

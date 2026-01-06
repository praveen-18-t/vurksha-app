import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Location and search header widget for home screen
/// Displays current location with search bar and notification bell
class LocationSearchHeaderWidget extends StatelessWidget {
  const LocationSearchHeaderWidget({
    super.key,
    required this.onSearchTap,
    required this.onNotificationTap,
  });

  final VoidCallback onSearchTap;
  final VoidCallback onNotificationTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Row(
        children: [
          // Location indicator
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'location_on',
                      color: theme.colorScheme.primary,
                      size: 16,
                    ),
                    SizedBox(width: 1.w),
                    Flexible(
                      child: Text(
                        'Delivering to',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Koramangala, Bangalore',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),

          SizedBox(width: 2.w),

          // Search button
          InkWell(
            onTap: onSearchTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: CustomIconWidget(
                iconName: 'search',
                color: theme.colorScheme.onSurface,
                size: 24,
              ),
            ),
          ),

          SizedBox(width: 2.w),

          // Notification bell
          InkWell(
            onTap: onNotificationTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CustomIconWidget(
                    iconName: 'notifications_outlined',
                    color: theme.colorScheme.onSurface,
                    size: 24,
                  ),
                  // Notification badge
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

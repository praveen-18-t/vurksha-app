import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Profile Header Widget - User avatar and basic info
class ProfileHeaderWidget extends StatelessWidget {
  final Map<String, dynamic> userData;
  final VoidCallback onEditProfile;
  final VoidCallback onAvatarTap;

  const ProfileHeaderWidget({
    super.key,
    required this.userData,
    required this.onEditProfile,
    required this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 100.w,
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Avatar
          GestureDetector(
            onTap: onAvatarTap,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CustomImageWidget(
                  imageUrl: userData['avatar'] as String?,
                  height: 20.w,
                  width: 20.w,
                  radius: BorderRadius.circular(10.w),
                  fit: BoxFit.cover,
                  placeHolder: 'assets/images/person_placeholder.png', // A more specific placeholder
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.colorScheme.surface, width: 2),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: theme.colorScheme.onPrimary,
                      size: 3.w,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 2.h),
          
          // User Name
          Text(
            userData['name'] ?? 'John Doe',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          
          SizedBox(height: 0.5.h),
          
          // User Email
          Text(
            userData['email'] ?? 'john.doe@example.com',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          
          SizedBox(height: 0.5.h),
          
          // User Phone
          Text(
            userData['phone'] ?? '+91 98765 43210',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          
          SizedBox(height: 0.5.h),
          
          // Member Since
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(2.h),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'calendar_today',
                  color: theme.colorScheme.primary,
                  size: 4.w,
                ),
                SizedBox(width: 1.w),
                Flexible(
                  child: Text(
                    'Member since ${userData['memberSince'] ?? 'Nov 2023'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

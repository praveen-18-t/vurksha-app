import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class SettingsTileWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  const SettingsTileWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary, size: 6.w),
      title: Text(title, style: theme.textTheme.titleSmall),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            )
          : null,
      trailing: trailing ?? Icon(Icons.arrow_forward_ios, size: 4.w),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
    );
  }
}

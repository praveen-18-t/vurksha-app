import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class CustomEmptyWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Future<void> Function()? onRefresh;

  const CustomEmptyWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 15.w,
          color: theme.colorScheme.primary.withValues(alpha: 0.5),
        ),
        SizedBox(height: 2.h),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );

    if (onRefresh != null) {
      return RefreshIndicator(
        onRefresh: onRefresh!,
        child: Stack(
          children: [
            ListView(), // Required for RefreshIndicator to work
            Center(child: content),
          ],
        ),
      );
    }

    return Center(child: content);
  }
}

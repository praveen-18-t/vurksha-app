import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class PrivacyControlsWidget extends StatelessWidget {
  const PrivacyControlsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(1.5.h),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Privacy & Data',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.download_for_offline_outlined),
            title: const Text('Download My Data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Download My Data - Coming Soon')),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.delete_forever_outlined, color: theme.colorScheme.error),
            title: Text('Delete Account', style: TextStyle(color: theme.colorScheme.error)),
            trailing: Icon(Icons.chevron_right, color: theme.colorScheme.error),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Delete Account - Coming Soon')),
              );
            },
          ),
        ],
      ),
    );
  }
}

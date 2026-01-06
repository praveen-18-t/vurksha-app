import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class SecuritySettingsWidget extends StatefulWidget {
  final bool isTwoFactorEnabled;
  final Function(bool) onTwoFactorChanged;

  const SecuritySettingsWidget({
    super.key,
    required this.isTwoFactorEnabled,
    required this.onTwoFactorChanged,
  });

  @override
  State<SecuritySettingsWidget> createState() => _SecuritySettingsWidgetState();
}

class _SecuritySettingsWidgetState extends State<SecuritySettingsWidget> {
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
            'Security',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.password),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Change Password - Coming Soon')),
              );
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.phonelink_lock),
            title: const Text('Two-Factor Authentication'),
            value: widget.isTwoFactorEnabled,
            onChanged: widget.onTwoFactorChanged,
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Login History'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Login History - Coming Soon')),
              );
            },
          ),
        ],
      ),
    );
  }
}

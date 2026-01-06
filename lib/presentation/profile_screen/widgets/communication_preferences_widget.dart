import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class CommunicationPreferencesWidget extends StatelessWidget {
  final bool marketingEmails;
  final bool smsNotifications;
  final bool pushNotifications;
  final Function(bool) onMarketingEmailsChanged;
  final Function(bool) onSmsNotificationsChanged;
  final Function(bool) onPushNotificationsChanged;

  const CommunicationPreferencesWidget({
    super.key,
    required this.marketingEmails,
    required this.smsNotifications,
    required this.pushNotifications,
    required this.onMarketingEmailsChanged,
    required this.onSmsNotificationsChanged,
    required this.onPushNotificationsChanged,
  });

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
            'Communication Preferences',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(),
          SwitchListTile(
            secondary: const Icon(Icons.email_outlined),
            title: const Text('Marketing Emails'),
            value: marketingEmails,
            onChanged: onMarketingEmailsChanged,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.sms_outlined),
            title: const Text('SMS Notifications'),
            value: smsNotifications,
            onChanged: onSmsNotificationsChanged,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active_outlined),
            title: const Text('Push Notifications'),
            value: pushNotifications,
            onChanged: onPushNotificationsChanged,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../data/models/notification_model.dart';
import 'package:time_range_picker/time_range_picker.dart';

class NotificationSettingsWidget extends StatefulWidget {
  final NotificationSettings settings;
  final Function(NotificationSettings) onSettingsChanged;

  const NotificationSettingsWidget({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  State<NotificationSettingsWidget> createState() =>
      _NotificationSettingsWidgetState();
}

class _NotificationSettingsWidgetState extends State<NotificationSettingsWidget> {
  late NotificationSettings _currentSettings;

  @override
  void initState() {
    super.initState();
    _currentSettings = widget.settings.copyWith();
  }

  void _onChanged() {
    widget.onSettingsChanged(_currentSettings);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Channels', theme),
          _buildSwitchTile(
            'Push Notifications',
            'Receive updates via push notifications',
            _currentSettings.pushNotificationsEnabled,
            (value) {
              setState(() => _currentSettings.pushNotificationsEnabled = value);
              _onChanged();
            },
            theme,
          ),
          _buildSwitchTile(
            'Email Notifications',
            'Receive updates via email',
            _currentSettings.emailNotificationsEnabled,
            (value) {
              setState(() => _currentSettings.emailNotificationsEnabled = value);
              _onChanged();
            },
            theme,
          ),
          _buildSwitchTile(
            'SMS Notifications',
            'Receive updates via SMS',
            _currentSettings.smsNotificationsEnabled,
            (value) {
              setState(() => _currentSettings.smsNotificationsEnabled = value);
              _onChanged();
            },
            theme,
          ),
          SizedBox(height: 2.h),
          _buildSectionTitle('Preferences', theme),
          _buildSwitchTile(
            'Sound',
            'Play sound for new notifications',
            _currentSettings.soundEnabled,
            (value) {
              setState(() => _currentSettings.soundEnabled = value);
              _onChanged();
            },
            theme,
          ),
          _buildSwitchTile(
            'Vibration',
            'Vibrate for new notifications',
            _currentSettings.vibrationEnabled,
            (value) {
              setState(() => _currentSettings.vibrationEnabled = value);
              _onChanged();
            },
            theme,
          ),
          _buildQuietHoursTile(theme),
          SizedBox(height: 2.h),
          _buildSectionTitle('Categories', theme),
          ...NotificationCategory.values
              .where((c) => c != NotificationCategory.other)
              .map((category) {
            return _buildSwitchTile(
              _getCategoryName(category),
              'Receive updates for this category',
              _currentSettings.categorySettings[category] ?? true,
              (value) {
                setState(() => _currentSettings.categorySettings[category] = value);
                _onChanged();
              },
              theme,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    ThemeData theme,
  ) {
    return SwitchListTile(
      title: Text(title, style: theme.textTheme.titleSmall),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
      value: value,
      onChanged: onChanged,
      activeThumbColor: theme.colorScheme.primary,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildQuietHoursTile(ThemeData theme) {
    return ListTile(
      title: Text('Quiet Hours', style: theme.textTheme.titleSmall),
      subtitle: Text(
        _currentSettings.quietHoursStart != null &&
                _currentSettings.quietHoursEnd != null
            ? 'From ${_currentSettings.quietHoursStart!.format(context)} to ${_currentSettings.quietHoursEnd!.format(context)}'
            : 'Mute notifications during specific hours',
        style: theme.textTheme.bodySmall,
      ),
      onTap: _selectQuietHours,
      contentPadding: EdgeInsets.zero,
      trailing: Icon(Icons.arrow_forward_ios, size: 4.w),
    );
  }

  Future<void> _selectQuietHours() async {
    final TimeRange? result = await showTimeRangePicker(
      context: context,
      start: _currentSettings.quietHoursStart,
      end: _currentSettings.quietHoursEnd,
    );

    if (result != null) {
      setState(() {
        _currentSettings.quietHoursStart = result.startTime;
        _currentSettings.quietHoursEnd = result.endTime;
      });
      _onChanged();
    }
  }

  String _getCategoryName(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.orderUpdates:
        return 'Order Updates';
      case NotificationCategory.promotionalOffers:
        return 'Promotional Offers';
      case NotificationCategory.accountAlerts:
        return 'Account Alerts';
      case NotificationCategory.paymentNotifications:
        return 'Payment Notifications';
      case NotificationCategory.deliveryUpdates:
        return 'Delivery Updates';
      case NotificationCategory.other:
        return 'Other';
    }
  }
}

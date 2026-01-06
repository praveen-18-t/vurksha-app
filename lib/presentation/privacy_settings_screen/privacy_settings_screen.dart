import 'package:flutter/material.dart';

import '../../data/models/privacy_settings_model.dart';
import '../settings_screen/widgets/settings_tile_widget.dart';

class PrivacySettingsScreen extends StatefulWidget {
  final PrivacySettingsModel settings;
  final Function(PrivacySettingsModel) onSettingsChanged;

  const PrivacySettingsScreen({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  late PrivacySettingsModel _currentSettings;

  @override
  void initState() {
    super.initState();
    _currentSettings = widget.settings.copyWith();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Settings'),
      ),
      body: ListView(
        children: [
          SettingsTileWidget(
            icon: Icons.analytics_outlined,
            title: 'Share Analytics Data',
            subtitle: 'Help improve the app by sharing anonymous usage data',
            onTap: () {},
            trailing: Switch(
              value: _currentSettings.shareAnalyticsData,
              onChanged: (value) {
                setState(() {
                  _currentSettings = _currentSettings.copyWith(shareAnalyticsData: value);
                });
                widget.onSettingsChanged(_currentSettings);
              },
            ),
          ),
          SettingsTileWidget(
            icon: Icons.location_on_outlined,
            title: 'Location Access',
            subtitle: 'Allow the app to access your location for better service',
            onTap: () {},
            trailing: Switch(
              value: _currentSettings.allowLocationAccess,
              onChanged: (value) {
                setState(() {
                  _currentSettings = _currentSettings.copyWith(allowLocationAccess: value);
                });
                widget.onSettingsChanged(_currentSettings);
              },
            ),
          ),
          SettingsTileWidget(
            icon: Icons.camera_alt_outlined,
            title: 'Camera Access',
            subtitle: 'Allow the app to use your camera for scanning QR codes',
            onTap: () {},
            trailing: Switch(
              value: _currentSettings.allowCameraAccess,
              onChanged: (value) {
                setState(() {
                  _currentSettings = _currentSettings.copyWith(allowCameraAccess: value);
                });
                widget.onSettingsChanged(_currentSettings);
              },
            ),
          ),
          SettingsTileWidget(
            icon: Icons.notifications_active_outlined,
            title: 'Notification Access',
            subtitle: 'Allow the app to send you notifications',
            onTap: () {},
            trailing: Switch(
              value: _currentSettings.allowNotificationAccess,
              onChanged: (value) {
                setState(() {
                  _currentSettings = _currentSettings.copyWith(allowNotificationAccess: value);
                });
                widget.onSettingsChanged(_currentSettings);
              },
            ),
          ),
        ],
      ),
    );
  }
}

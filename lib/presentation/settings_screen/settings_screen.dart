import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../data/models/settings_model.dart';
import '../../data/models/user_model.dart';
import '../notification_screen/notification_screen.dart';
import '../profile_management_screen/profile_management_screen.dart';
import '../theme_display_screen/theme_display_screen.dart';
import '../language_screen/language_screen.dart';
import '../privacy_settings_screen/privacy_settings_screen.dart';
import '../help_center_screen/help_center_screen.dart';
import '../about_screen/about_screen.dart';
import '../../data/models/privacy_settings_model.dart';
import 'widgets/settings_group_widget.dart';
import 'widgets/settings_tile_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final UserModel _user;
  late AppSettingsModel _appSettings;
  late PrivacySettingsModel _privacySettings;

  @override
  void initState() {
    super.initState();
    // In a real app, this user data would be fetched from a repository or state management solution.
    _user = UserModel(
      uid: '12345',
      name: 'Praveen Kumar',
      email: 'praveen.kumar@example.com',
      phoneNumber: '+91 98765 43210',
      profilePictureUrl: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=880&q=80',
    );
    _appSettings = AppSettingsModel();
    _privacySettings = PrivacySettingsModel();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
        child: Column(
          children: [
            // Account Settings
            SettingsGroupWidget(
              title: 'Account',
              children: [
                SettingsTileWidget(
                  icon: Icons.person_outline,
                  title: 'Profile Management',
                  subtitle: 'Edit name, email, and password',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileManagementScreen(user: _user),
                      ),
                    );
                  },
                ),
                SettingsTileWidget(
                  icon: Icons.notifications_none_outlined,
                  title: 'Notification Preferences',
                  subtitle: 'Manage how you get updates',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationScreen(),
                      ),
                    );
                  },
                ),
                SettingsTileWidget(
                  icon: Icons.exit_to_app,
                  title: 'Logout',
                  subtitle: 'Sign out of your account',
                  onTap: () => _showLogoutDialog(context),
                ),
              ],
            ),
            // App Settings
            SettingsGroupWidget(
              title: 'App Settings',
              children: [
                SettingsTileWidget(
                  icon: Icons.palette_outlined,
                  title: 'Theme & Display',
                  subtitle: 'Switch between light and dark mode',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ThemeDisplayScreen(
                          settings: _appSettings,
                          onThemeChanged: (theme) {
                            setState(() {
                              _appSettings = _appSettings.copyWith(theme: theme);
                            });
                            // Here you would typically use a state management solution
                            // to apply the theme change across the app.
                          },
                        ),
                      ),
                    );
                  },
                ),
                SettingsTileWidget(
                  icon: Icons.language_outlined,
                  title: 'Language',
                  subtitle: 'Select your preferred language',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LanguageScreen(
                          settings: _appSettings,
                          onLanguageChanged: (code) {
                            setState(() {
                              _appSettings = _appSettings.copyWith(languageCode: code);
                            });
                            // Here you would typically use a localization package
                            // to apply the language change across the app.
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            // Security
            SettingsGroupWidget(
              title: 'Security',
              children: [
                SettingsTileWidget(
                  icon: Icons.security_outlined,
                  title: 'Privacy Settings',
                  subtitle: 'Manage data sharing and permissions',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PrivacySettingsScreen(
                          settings: _privacySettings,
                          onSettingsChanged: (settings) {
                            setState(() {
                              _privacySettings = settings;
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
                SettingsTileWidget(
                  icon: Icons.fingerprint,
                  title: 'Biometric Login',
                  subtitle: 'Use Face ID or fingerprint',
                  onTap: () {},
                  trailing: Switch(
                    value: _appSettings.isBiometricEnabled,
                    onChanged: (value) {
                      setState(() {
                        _appSettings = _appSettings.copyWith(isBiometricEnabled: value);
                      });
                    },
                  ),
                ),
              ],
            ),
            // Support
            SettingsGroupWidget(
              title: 'Support',
              children: [
                SettingsTileWidget(
                  icon: Icons.help_outline,
                  title: 'Help Center',
                  subtitle: 'Find answers to your questions',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HelpCenterScreen(),
                      ),
                    );
                  },
                ),
                SettingsTileWidget(
                  icon: Icons.info_outline,
                  title: 'About',
                  subtitle: 'App version, terms, and policies',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AboutScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Logout',
          style: theme.textTheme.titleLarge,
        ),
        content: Text(
          'Are you sure you want to logout from your account?',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Clear user session data
              try {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                
                // In a real app, you would also:
                // - Sign out from Firebase
                // - Clear any cached user data
                // - Reset app state management
                
                if (context.mounted) {
                  Navigator.pushReplacementNamed(
                    context, 
                    '/phone-authentication-screen'
                  );
                }
              } catch (e) {
                // Handle error during logout
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error during logout'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../data/models/settings_model.dart';

class ThemeDisplayScreen extends StatefulWidget {
  final AppSettingsModel settings;
  final Function(AppTheme) onThemeChanged;

  const ThemeDisplayScreen({
    super.key,
    required this.settings,
    required this.onThemeChanged,
  });

  @override
  State<ThemeDisplayScreen> createState() => _ThemeDisplayScreenState();
}

class _ThemeDisplayScreenState extends State<ThemeDisplayScreen> {
  late AppTheme _selectedTheme;

  @override
  void initState() {
    super.initState();
    _selectedTheme = widget.settings.theme;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme & Display'),
      ),
      body: RadioGroup<AppTheme>(
        groupValue: _selectedTheme,
        onChanged: (value) {
          if (value == null) return;
          setState(() => _selectedTheme = value);
          widget.onThemeChanged(value);
        },
        child: Column(
          children: const [
            RadioListTile<AppTheme>(
              title: Text('Light'),
              value: AppTheme.light,
            ),
            RadioListTile<AppTheme>(
              title: Text('Dark'),
              value: AppTheme.dark,
            ),
            RadioListTile<AppTheme>(
              title: Text('System Default'),
              value: AppTheme.system,
            ),
          ],
        ),
      ),
    );
  }
}

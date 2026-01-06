import 'package:flutter/material.dart';

import '../../data/models/settings_model.dart';

class LanguageScreen extends StatefulWidget {
  final AppSettingsModel settings;
  final Function(String) onLanguageChanged;

  const LanguageScreen({
    super.key,
    required this.settings,
    required this.onLanguageChanged,
  });

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  late String _selectedLanguage;

  // In a real app, this would come from a localization service.
  final Map<String, String> _languages = {
    'en': 'English',
    'es': 'Español',
    'fr': 'Français',
    'de': 'Deutsch',
    'hi': 'हिन्दी',
  };

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.settings.languageCode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Language'),
      ),
      body: RadioGroup<String>(
        groupValue: _selectedLanguage,
        onChanged: (value) {
          if (value == null) return;
          setState(() => _selectedLanguage = value);
          widget.onLanguageChanged(value);
        },
        child: ListView.builder(
          itemCount: _languages.length,
          itemBuilder: (context, index) {
            final code = _languages.keys.elementAt(index);
            final name = _languages.values.elementAt(index);
            return RadioListTile<String>(
              title: Text(name),
              value: code,
            );
          },
        ),
      ),
    );
  }
}

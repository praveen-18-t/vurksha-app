enum AppTheme { light, dark, system }

class AppSettingsModel {
  final AppTheme theme;
  final String languageCode;
  final bool isBiometricEnabled;

  AppSettingsModel({
    this.theme = AppTheme.system,
    this.languageCode = 'en',
    this.isBiometricEnabled = false,
  });

  AppSettingsModel copyWith({
    AppTheme? theme,
    String? languageCode,
    bool? isBiometricEnabled,
  }) {
    return AppSettingsModel(
      theme: theme ?? this.theme,
      languageCode: languageCode ?? this.languageCode,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
    );
  }
}

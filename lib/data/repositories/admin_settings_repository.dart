import '../models/admin_settings_model.dart';

class AdminSettingsRepository {
  // Mock database
  AdminSettingsModel _settings = AdminSettingsModel(
    storeOpen: true,
    deliveryRadius: 25.0,
    codEnabled: true,
    stripeEnabled: true,
  );

  // Get settings
  Future<AdminSettingsModel> getSettings() async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay
    return _settings;
  }

  // Save settings
  Future<void> saveSettings(AdminSettingsModel newSettings) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _settings = newSettings;
  }
}

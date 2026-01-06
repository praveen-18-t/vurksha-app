class PrivacySettingsModel {
  final bool shareAnalyticsData;
  final bool allowLocationAccess;
  final bool allowCameraAccess;
  final bool allowNotificationAccess;

  PrivacySettingsModel({
    this.shareAnalyticsData = true,
    this.allowLocationAccess = false,
    this.allowCameraAccess = false,
    this.allowNotificationAccess = true,
  });

  PrivacySettingsModel copyWith({
    bool? shareAnalyticsData,
    bool? allowLocationAccess,
    bool? allowCameraAccess,
    bool? allowNotificationAccess,
  }) {
    return PrivacySettingsModel(
      shareAnalyticsData: shareAnalyticsData ?? this.shareAnalyticsData,
      allowLocationAccess: allowLocationAccess ?? this.allowLocationAccess,
      allowCameraAccess: allowCameraAccess ?? this.allowCameraAccess,
      allowNotificationAccess:
          allowNotificationAccess ?? this.allowNotificationAccess,
    );
  }
}

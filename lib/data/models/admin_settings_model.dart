class AdminSettingsModel {
  final bool storeOpen;
  final double deliveryRadius;
  final bool codEnabled;
  final bool stripeEnabled;

  AdminSettingsModel({
    required this.storeOpen,
    required this.deliveryRadius,
    required this.codEnabled,
    required this.stripeEnabled,
  });

  AdminSettingsModel copyWith({
    bool? storeOpen,
    double? deliveryRadius,
    bool? codEnabled,
    bool? stripeEnabled,
  }) {
    return AdminSettingsModel(
      storeOpen: storeOpen ?? this.storeOpen,
      deliveryRadius: deliveryRadius ?? this.deliveryRadius,
      codEnabled: codEnabled ?? this.codEnabled,
      stripeEnabled: stripeEnabled ?? this.stripeEnabled,
    );
  }
}

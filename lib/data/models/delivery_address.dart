class DeliveryAddress {
  final String id;
  final String name;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String pincode;
  final String phone;
  final bool isDefault;

  DeliveryAddress({
    required this.id,
    required this.name,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.pincode,
    required this.phone,
    this.isDefault = false,
  });
}

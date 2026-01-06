enum AddressType {
  home,
  work,
  other,
}

class DeliveryAddress {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String pinCode;
  final String country;
  final AddressType type;
  final bool isDefault;
  final double? latitude;
  final double? longitude;
  final DeliveryInstructions? deliveryInstructions;
  final DateTime createdAt;
  final DateTime updatedAt;

  DeliveryAddress({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.pinCode,
    required this.country,
    required this.type,
    this.isDefault = false,
    this.latitude,
    this.longitude,
    this.deliveryInstructions,
    required this.createdAt,
    required this.updatedAt,
  });

  DeliveryAddress copyWith({
    String? id,
    String? fullName,
    String? phoneNumber,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? pinCode,
    String? country,
    AddressType? type,
    bool? isDefault,
    double? latitude,
    double? longitude,
    DeliveryInstructions? deliveryInstructions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DeliveryAddress(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      pinCode: pinCode ?? this.pinCode,
      country: country ?? this.country,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      deliveryInstructions: deliveryInstructions ?? this.deliveryInstructions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get fullAddress {
    final parts = [
      addressLine1,
      if (addressLine2.isNotEmpty) addressLine2,
      city,
      state,
      pinCode,
      country,
    ];
    return parts.where((part) => part.isNotEmpty).join(', ');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'pinCode': pinCode,
      'country': country,
      'type': type.name,
      'isDefault': isDefault,
      'latitude': latitude,
      'longitude': longitude,
      'deliveryInstructions': deliveryInstructions?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      phoneNumber: json['phoneNumber'] as String,
      addressLine1: json['addressLine1'] as String,
      addressLine2: json['addressLine2'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      pinCode: json['pinCode'] as String,
      country: json['country'] as String,
      type: AddressType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AddressType.other,
      ),
      isDefault: json['isDefault'] as bool? ?? false,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      deliveryInstructions: json['deliveryInstructions'] != null
          ? DeliveryInstructions.fromJson(json['deliveryInstructions'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class DeliveryInstructions {
  final String specialNotes;
  final String securityCode;
  final String preferredTimeSlot;

  DeliveryInstructions({
    this.specialNotes = '',
    this.securityCode = '',
    this.preferredTimeSlot = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'specialNotes': specialNotes,
      'securityCode': securityCode,
      'preferredTimeSlot': preferredTimeSlot,
    };
  }

  factory DeliveryInstructions.fromJson(Map<String, dynamic> json) {
    return DeliveryInstructions(
      specialNotes: json['specialNotes'] as String? ?? '',
      securityCode: json['securityCode'] as String? ?? '',
      preferredTimeSlot: json['preferredTimeSlot'] as String? ?? '',
    );
  }
}

class AddressValidationResult {
  final bool isValid;
  final bool isServiceable;
  final String? errorMessage;
  final List<String> suggestions;

  AddressValidationResult({
    required this.isValid,
    required this.isServiceable,
    this.errorMessage,
    this.suggestions = const [],
  });

  factory AddressValidationResult.success() {
    return AddressValidationResult(
      isValid: true,
      isServiceable: true,
    );
  }

  factory AddressValidationResult.error(String message) {
    return AddressValidationResult(
      isValid: false,
      isServiceable: false,
      errorMessage: message,
    );
  }

  factory AddressValidationResult.notServiceable(List<String> suggestions) {
    return AddressValidationResult(
      isValid: true,
      isServiceable: false,
      suggestions: suggestions,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../data/models/address_model.dart';
import '../../../widgets/custom_icon_widget.dart';

class AddressFormWidget extends StatelessWidget {
  final TextEditingController fullNameController;
  final TextEditingController phoneController;
  final TextEditingController addressLine1Controller;
  final TextEditingController addressLine2Controller;
  final TextEditingController cityController;
  final TextEditingController stateController;
  final TextEditingController pinCodeController;
  final TextEditingController countryController;
  final AddressType selectedType;
  final bool isDefault;
  final double? latitude;
  final double? longitude;
  final Function(AddressType) onTypeChanged;
  final Function(bool) onDefaultChanged;
  final VoidCallback onLocationTap;
  final VoidCallback onUseCurrentLocation;

  const AddressFormWidget({
    super.key,
    required this.fullNameController,
    required this.phoneController,
    required this.addressLine1Controller,
    required this.addressLine2Controller,
    required this.cityController,
    required this.stateController,
    required this.pinCodeController,
    required this.countryController,
    required this.selectedType,
    required this.isDefault,
    this.latitude,
    this.longitude,
    required this.onTypeChanged,
    required this.onDefaultChanged,
    required this.onLocationTap,
    required this.onUseCurrentLocation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Address type selection
          Text(
            'Address Type',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: AddressType.values.map((type) {
              final isSelected = selectedType == type;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: type != AddressType.other ? 2.w : 0),
                  child: InkWell(
                    onTap: () => onTypeChanged(type),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.dividerColor,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getAddressTypeIcon(type),
                            size: 4.w,
                            color: isSelected
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurface,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            _getAddressTypeText(type),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isSelected
                                  ? theme.colorScheme.onPrimary
                                  : theme.colorScheme.onSurface,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          SizedBox(height: 2.h),

          // Contact information
          Text(
            'Contact Information',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          TextFormField(
            controller: fullNameController,
            decoration: const InputDecoration(
              labelText: 'Full Name *',
              hintText: 'Enter your full name',
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your full name';
              }
              return null;
            },
          ),
          SizedBox(height: 1.h),
          TextFormField(
            controller: phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone Number *',
              hintText: 'Enter your phone number',
              prefixIcon: Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your phone number';
              }
              if (value.length < 10) {
                return 'Please enter a valid phone number';
              }
              return null;
            },
          ),

          SizedBox(height: 2.h),

          // Address fields
          Text(
            'Address Details',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          TextFormField(
            controller: addressLine1Controller,
            decoration: const InputDecoration(
              labelText: 'Address Line 1 *',
              hintText: 'House no, building, street',
              prefixIcon: Icon(Icons.home),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter address line 1';
              }
              return null;
            },
          ),
          SizedBox(height: 1.h),
          TextFormField(
            controller: addressLine2Controller,
            decoration: const InputDecoration(
              labelText: 'Address Line 2',
              hintText: 'Area, locality, landmark',
              prefixIcon: Icon(Icons.location_city),
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: cityController,
                  decoration: const InputDecoration(
                    labelText: 'City/District *',
                    hintText: 'Enter city',
                    prefixIcon: Icon(Icons.location_city),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter city';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: TextFormField(
                  controller: stateController,
                  decoration: const InputDecoration(
                    labelText: 'State *',
                    hintText: 'Enter state',
                    prefixIcon: Icon(Icons.map),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter state';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: pinCodeController,
                  decoration: const InputDecoration(
                    labelText: 'PIN/ZIP Code *',
                    hintText: 'Enter PIN code',
                    prefixIcon: Icon(Icons.local_post_office),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter PIN code';
                    }
                    if (value.length != 6) {
                      return 'Please enter a valid PIN code';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: TextFormField(
                  controller: countryController,
                  decoration: const InputDecoration(
                    labelText: 'Country *',
                    hintText: 'Enter country',
                    prefixIcon: Icon(Icons.public),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter country';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Location selection
          Text(
            'Location',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'location_on',
                      color: latitude != null && longitude != null
                          ? Colors.green
                          : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      size: 4.w,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        latitude != null && longitude != null
                            ? 'Location selected (${latitude!.toStringAsFixed(4)}, ${longitude!.toStringAsFixed(4)})'
                            : 'No location selected',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: latitude != null && longitude != null
                              ? Colors.green
                              : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onLocationTap,
                        icon: const Icon(Icons.map),
                        label: const Text('Select on Map'),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onUseCurrentLocation,
                        icon: const Icon(Icons.my_location),
                        label: const Text('Use Current'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 2.h),

          // Default address checkbox
          Row(
            children: [
              Checkbox(
                value: isDefault,
                onChanged: (value) => onDefaultChanged(value ?? false),
                activeColor: theme.colorScheme.primary,
              ),
              Expanded(
                child: Text(
                  'Set as default delivery address',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getAddressTypeIcon(AddressType type) {
    switch (type) {
      case AddressType.home:
        return Icons.home;
      case AddressType.work:
        return Icons.work;
      case AddressType.other:
        return Icons.location_on;
    }
  }

  String _getAddressTypeText(AddressType type) {
    switch (type) {
      case AddressType.home:
        return 'Home';
      case AddressType.work:
        return 'Work';
      case AddressType.other:
        return 'Other';
    }
  }
}

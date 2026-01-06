import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../data/models/address_model.dart';
import '../../../widgets/custom_app_bar.dart';
import '../models/lat_lng.dart';
import 'address_form_widget.dart';
import 'location_picker_widget.dart';
import 'delivery_instructions_widget.dart';

class AddEditAddressWidget extends StatefulWidget {
  final DeliveryAddress? address;
  final Function(DeliveryAddress) onSave;

  const AddEditAddressWidget({
    super.key,
    this.address,
    required this.onSave,
  });

  @override
  State<AddEditAddressWidget> createState() => _AddEditAddressWidgetState();
}

class _AddEditAddressWidgetState extends State<AddEditAddressWidget> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressLine1Controller;
  late TextEditingController _addressLine2Controller;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _pinCodeController;
  late TextEditingController _countryController;
  
  AddressType _selectedType = AddressType.home;
  bool _isDefault = false;
  double? _latitude;
  double? _longitude;
  
  DeliveryInstructions _deliveryInstructions = DeliveryInstructions();
  
  bool _isLoading = false;
  bool _showLocationPicker = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    if (widget.address != null) {
      final address = widget.address!;
      _fullNameController = TextEditingController(text: address.fullName);
      _phoneController = TextEditingController(text: address.phoneNumber);
      _addressLine1Controller = TextEditingController(text: address.addressLine1);
      _addressLine2Controller = TextEditingController(text: address.addressLine2);
      _cityController = TextEditingController(text: address.city);
      _stateController = TextEditingController(text: address.state);
      _pinCodeController = TextEditingController(text: address.pinCode);
      _countryController = TextEditingController(text: address.country);
      _selectedType = address.type;
      _isDefault = address.isDefault;
      _latitude = address.latitude;
      _longitude = address.longitude;
      _deliveryInstructions = address.deliveryInstructions ?? DeliveryInstructions();
    } else {
      _fullNameController = TextEditingController();
      _phoneController = TextEditingController();
      _addressLine1Controller = TextEditingController();
      _addressLine2Controller = TextEditingController();
      _cityController = TextEditingController();
      _stateController = TextEditingController();
      _pinCodeController = TextEditingController();
      _countryController = TextEditingController(text: 'India');
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pinCodeController.dispose();
    _countryController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onLocationSelected(double lat, double lng) {
    setState(() {
      _latitude = lat;
      _longitude = lng;
      _showLocationPicker = false;
    });
  }

  void _onUseCurrentLocation() async {
    // Simulate getting current location
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _latitude = 18.5333;
      _longitude = 73.8567;
      _isLoading = false;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Current location detected')),
      );
    }
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) {
      _scrollToFirstError();
      return;
    }

    setState(() => _isLoading = true);

    // Validate address
    final validationResult = await _validateAddress();
    
    if (!validationResult.isValid) {
      setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationResult.errorMessage ?? 'Invalid address'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
      return;
    }

    if (!validationResult.isServiceable) {
      setState(() => _isLoading = false);
      _showServiceabilityError(validationResult.suggestions);
      return;
    }

    final address = DeliveryAddress(
      id: widget.address?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      fullName: _fullNameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      addressLine1: _addressLine1Controller.text.trim(),
      addressLine2: _addressLine2Controller.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      pinCode: _pinCodeController.text.trim(),
      country: _countryController.text.trim(),
      type: _selectedType,
      isDefault: _isDefault,
      latitude: _latitude,
      longitude: _longitude,
      deliveryInstructions: _deliveryInstructions,
      createdAt: widget.address?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setState(() => _isLoading = false);
    widget.onSave(address);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<AddressValidationResult> _validateAddress() async {
    // Simulate API validation
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock validation logic
    if (_pinCodeController.text.length != 6) {
      return AddressValidationResult.error('Invalid PIN code');
    }
    
    // Mock serviceability check
    final nonServiceablePincodes = ['400001', '400002'];
    if (nonServiceablePincodes.contains(_pinCodeController.text)) {
      return AddressValidationResult.notServiceable([
        'Try nearby area: 400003',
        'Try nearby area: 400004',
      ]);
    }
    
    return AddressValidationResult.success();
  }

  void _scrollToFirstError() {
    // Scroll to first error field
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void _showServiceabilityError(List<String> suggestions) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Not Serviceable'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('We currently don\'t deliver to this location.'),
            const SizedBox(height: 16),
            if (suggestions.isNotEmpty) ...[
              const Text('Try these nearby areas:'),
              const SizedBox(height: 8),
              ...suggestions.map((suggestion) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• $suggestion'),
              )),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        variant: AppBarVariant.standard,
        title: Text(widget.address == null ? 'Add Address' : 'Edit Address'),
        showBackButton: true,
      ),
      body: _showLocationPicker
          ? LocationPickerWidget(
              initialLocation: _latitude != null && _longitude != null
                  ? LatLng(_latitude!, _longitude!)
                  : null,
              onLocationSelected: _onLocationSelected,
              onBack: () => setState(() => _showLocationPicker = false),
            )
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Address form
                    AddressFormWidget(
                      fullNameController: _fullNameController,
                      phoneController: _phoneController,
                      addressLine1Controller: _addressLine1Controller,
                      addressLine2Controller: _addressLine2Controller,
                      cityController: _cityController,
                      stateController: _stateController,
                      pinCodeController: _pinCodeController,
                      countryController: _countryController,
                      selectedType: _selectedType,
                      isDefault: _isDefault,
                      latitude: _latitude,
                      longitude: _longitude,
                      onTypeChanged: (type) => setState(() => _selectedType = type),
                      onDefaultChanged: (value) => setState(() => _isDefault = value),
                      onLocationTap: () => setState(() => _showLocationPicker = true),
                      onUseCurrentLocation: _onUseCurrentLocation,
                    ),

                    SizedBox(height: 2.h),

                    // Delivery instructions
                    DeliveryInstructionsWidget(
                      instructions: _deliveryInstructions,
                      onChanged: (instructions) => setState(() => _deliveryInstructions = instructions),
                    ),

                    SizedBox(height: 4.h),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveAddress,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                widget.address == null ? 'Add Address' : 'Update Address',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            ),
    );
  }
}

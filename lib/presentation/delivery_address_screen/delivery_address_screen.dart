import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/address_model.dart';
import '../../data/providers/address_provider.dart';
import '../../widgets/custom_app_bar.dart';
import 'widgets/address_book_widget.dart';
import 'widgets/add_edit_address_widget.dart';

class DeliveryAddressScreen extends ConsumerStatefulWidget {
  const DeliveryAddressScreen({super.key, this.selectionMode = false});

  final bool selectionMode;

  @override
  ConsumerState<DeliveryAddressScreen> createState() => _DeliveryAddressScreenState();
}

class _DeliveryAddressScreenState extends ConsumerState<DeliveryAddressScreen> {

  @override
  void initState() {
    super.initState();
  }

  void _onAddAddress() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditAddressWidget(
          onSave: (address) => _saveAddress(address),
        ),
      ),
    );
  }

  void _onEditAddress(DeliveryAddress address) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditAddressWidget(
          address: address,
          onSave: (address) => _saveAddress(address),
        ),
      ),
    );
  }

  void _onDeleteAddress(String addressId) {
    ref.read(addressProvider.notifier).deleteById(addressId);
    _showSnackBar('Address deleted successfully');
  }

  void _onSetDefault(String addressId) {
    ref.read(addressProvider.notifier).setDefault(addressId);
    _showSnackBar('Default address updated');
  }

  Future<void> _saveAddress(DeliveryAddress address) async {
    await ref.read(addressProvider.notifier).addOrUpdate(address);
    _showSnackBar('Address saved successfully');
  }

  void _onSelectAddress(DeliveryAddress address) {
    if (!widget.selectionMode) return;
    Navigator.pop(context, address);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final addressState = ref.watch(addressProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        variant: AppBarVariant.standard,
        title: Text(widget.selectionMode ? 'Select Address' : 'Delivery Addresses'),
        showBackButton: true,
      ),
      body: addressState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : AddressBookWidget(
              addresses: addressState.addresses,
              onAddAddress: _onAddAddress,
              onEditAddress: _onEditAddress,
              onDeleteAddress: _onDeleteAddress,
              onSetDefault: _onSetDefault,
              onAddressTap: widget.selectionMode ? _onSelectAddress : null,
            ),
    );
  }
}

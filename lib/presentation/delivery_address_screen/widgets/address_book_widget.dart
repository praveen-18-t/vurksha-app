import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../data/models/address_model.dart';
import '../../../widgets/custom_icon_widget.dart';
import 'address_card_widget.dart';

class AddressBookWidget extends StatelessWidget {
  final List<DeliveryAddress> addresses;
  final VoidCallback onAddAddress;
  final Function(DeliveryAddress) onEditAddress;
  final Function(String) onDeleteAddress;
  final Function(String) onSetDefault;
  final Function(DeliveryAddress)? onAddressTap;

  const AddressBookWidget({
    super.key,
    required this.addresses,
    required this.onAddAddress,
    required this.onEditAddress,
    required this.onDeleteAddress,
    required this.onSetDefault,
    this.onAddressTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Header with Add button
        Padding(
          padding: EdgeInsets.all(4.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Saved Addresses',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              ElevatedButton.icon(
                onPressed: onAddAddress,
                icon: const Icon(Icons.add),
                label: const Text('Add New'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),

        // Address list
        if (addresses.isEmpty)
          _buildEmptyState(context, theme)
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final address = addresses[index];
              return AddressCardWidget(
                address: address,
                onEdit: () => onEditAddress(address),
                onDelete: () => _showDeleteConfirmation(context, address),
                onSetDefault: () => onSetDefault(address.id),
                onTap: onAddressTap == null ? null : () => onAddressTap!(address),
              );
            },
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'location_on',
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
            size: 15.w,
          ),
          SizedBox(height: 2.h),
          Text(
            'No saved addresses',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Add your first address for quick checkout',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          SizedBox(height: 3.h),
          ElevatedButton.icon(
            onPressed: onAddAddress,
            icon: const Icon(Icons.add),
            label: const Text('Add Address'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, DeliveryAddress address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Address'),
        content: Text('Are you sure you want to delete this address?\n\n${address.fullAddress}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDeleteAddress(address.id);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

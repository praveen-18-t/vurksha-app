import 'package:flutter/material.dart';
import '../../../data/models/address_model.dart';
import '../../../routes/app_routes.dart';

/// Address Selection Widget - Placeholder
class AddressSelectionWidget extends StatelessWidget {
  final DeliveryAddress? selectedAddress;
  final Function(DeliveryAddress) onAddressSelected;
  final VoidCallback onAddAddress;

  const AddressSelectionWidget({
    super.key,
    this.selectedAddress,
    required this.onAddressSelected,
    required this.onAddAddress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery Address',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (selectedAddress == null)
            Text(
              'No address selected',
              style: theme.textTheme.bodyMedium,
            )
          else
            Text(
              selectedAddress!.fullAddress,
              style: theme.textTheme.bodyMedium,
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.selectDeliveryAddress).then((value) {
                      if (value is DeliveryAddress) {
                        onAddressSelected(value);
                      }
                    });
                  },
                  child: Text(selectedAddress == null ? 'Select Address' : 'Change'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onAddAddress,
                  child: const Text('Add New'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../data/models/address_model.dart';
import '../../../widgets/custom_icon_widget.dart';

class AddressCardWidget extends StatelessWidget {
  final DeliveryAddress address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;
  final VoidCallback? onTap;

  const AddressCardWidget({
    super.key,
    required this.address,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: address.isDefault
                  ? theme.colorScheme.primary
                  : theme.dividerColor.withValues(alpha: 0.3),
              width: address.isDefault ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
          // Header with type and default badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            decoration: BoxDecoration(
              color: address.isDefault
                  ? theme.colorScheme.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                _buildAddressTypeIcon(theme, address.type),
                SizedBox(width: 2.w),
                Text(
                  _getAddressTypeText(address.type),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: address.isDefault
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                if (address.isDefault)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'DEFAULT',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Address details
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and phone
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        address.fullName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      address.phoneNumber,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),

                // Full address
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        address.fullAddress,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),

                // Delivery instructions if available
                if (address.deliveryInstructions != null) ...[
                  SizedBox(height: 1.h),
                  if (address.deliveryInstructions!.specialNotes.isNotEmpty)
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'note',
                          color: theme.colorScheme.primary,
                          size: 3.w,
                        ),
                        SizedBox(width: 1.w),
                        Expanded(
                          child: Text(
                            address.deliveryInstructions!.specialNotes,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (address.deliveryInstructions!.preferredTimeSlot.isNotEmpty)
                    SizedBox(height: 0.5.h),
                  if (address.deliveryInstructions!.preferredTimeSlot.isNotEmpty)
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'schedule',
                          color: theme.colorScheme.primary,
                          size: 3.w,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          'Preferred: ${address.deliveryInstructions!.preferredTimeSlot}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                ],

                SizedBox(height: 2.h),

                // Action buttons
                Row(
                  children: [
                    if (!address.isDefault)
                      TextButton.icon(
                        onPressed: onSetDefault,
                        icon: const Icon(Icons.star_border, size: 16),
                        label: const Text('Set as Default'),
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.primary,
                        ),
                      ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit'),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    TextButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete, size: 16),
                      label: const Text('Delete'),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressTypeIcon(ThemeData theme, AddressType type) {
    IconData iconData;
    Color iconColor;

    switch (type) {
      case AddressType.home:
        iconData = Icons.home;
        iconColor = Colors.green;
        break;
      case AddressType.work:
        iconData = Icons.work;
        iconColor = Colors.blue;
        break;
      case AddressType.other:
        iconData = Icons.location_on;
        iconColor = Colors.orange;
        break;
    }

    return Icon(
      iconData,
      color: iconColor,
      size: 4.w,
    );
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

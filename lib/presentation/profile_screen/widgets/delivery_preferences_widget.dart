import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class DeliveryPreferencesWidget extends StatelessWidget {
  final String? defaultAddress;

  const DeliveryPreferencesWidget({
    super.key,
    this.defaultAddress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(1.5.h),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery Preferences',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Default Address'),
            subtitle: Text(defaultAddress ?? 'Not set'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Manage Addresses - Coming Soon')),
              );
            },
          ),
        ],
      ),
    );
  }
}

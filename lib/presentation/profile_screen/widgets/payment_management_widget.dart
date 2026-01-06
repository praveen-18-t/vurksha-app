import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class PaymentManagementWidget extends StatelessWidget {
  final String? defaultPaymentMethod;

  const PaymentManagementWidget({
    super.key,
    this.defaultPaymentMethod,
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
            'Payment Management',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.credit_card),
            title: const Text('Default Payment Method'),
            subtitle: Text(defaultPaymentMethod ?? 'Not set'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Manage Payment Methods - Coming Soon')),
              );
            },
          ),
        ],
      ),
    );
  }
}

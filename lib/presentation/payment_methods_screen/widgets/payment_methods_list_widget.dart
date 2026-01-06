import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../data/models/payment_model.dart';
import '../../../widgets/custom_icon_widget.dart';
import 'payment_method_card_widget.dart';

class PaymentMethodsListWidget extends StatelessWidget {
  final List<PaymentMethod> paymentMethods;
  final VoidCallback onAddPaymentMethod;
  final Function(PaymentMethod) onEditPaymentMethod;
  final Function(String) onDeletePaymentMethod;
  final Function(String) onSetDefault;

  const PaymentMethodsListWidget({
    super.key,
    required this.paymentMethods,
    required this.onAddPaymentMethod,
    required this.onEditPaymentMethod,
    required this.onDeletePaymentMethod,
    required this.onSetDefault,
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
                'Saved Payment Methods',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              ElevatedButton.icon(
                onPressed: onAddPaymentMethod,
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

        // Payment methods list
        if (paymentMethods.isEmpty)
          _buildEmptyState(context, theme)
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            itemCount: paymentMethods.length,
            itemBuilder: (context, index) {
              final paymentMethod = paymentMethods[index];
              return PaymentMethodCardWidget(
                paymentMethod: paymentMethod,
                onEdit: () => onEditPaymentMethod(paymentMethod),
                onDelete: () => _showDeleteConfirmation(context, paymentMethod),
                onSetDefault: () => onSetDefault(paymentMethod.id),
              );
            },
          ),

        // Quick payment options
        SizedBox(height: 2.h),
        Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick Payment Options',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 1.5.h),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickPaymentOption(
                      context,
                      'UPI',
                      'upi',
                      'Scan QR or enter UPI ID',
                      theme,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: _buildQuickPaymentOption(
                      context,
                      'COD',
                      'money',
                      'Pay on delivery',
                      theme,
                    ),
                  ),
                ],
              ),
            ],
          ),
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
            iconName: 'credit_card',
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
            size: 15.w,
          ),
          SizedBox(height: 2.h),
          Text(
            'No saved payment methods',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Add a payment method for quick checkout',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          SizedBox(height: 3.h),
          ElevatedButton.icon(
            onPressed: onAddPaymentMethod,
            icon: const Icon(Icons.add),
            label: const Text('Add Payment Method'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPaymentOption(
    BuildContext context,
    String title,
    String iconName,
    String description,
    ThemeData theme,
  ) {
    return InkWell(
      onTap: () {
        // Handle quick payment option
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title payment selected')),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: theme.colorScheme.primary,
              size: 6.w,
            ),
            SizedBox(height: 1.h),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, PaymentMethod paymentMethod) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payment Method'),
        content: Text('Are you sure you want to delete this payment method?\n\n${paymentMethod.displayName}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDeletePaymentMethod(paymentMethod.id);
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

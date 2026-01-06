import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../data/models/payment_model.dart';
import '../../../widgets/custom_app_bar.dart';

class AddPaymentMethodWidget extends StatefulWidget {
  final PaymentMethod? paymentMethod;
  final Function(PaymentMethod) onPaymentMethodAdded;

  const AddPaymentMethodWidget({
    super.key,
    this.paymentMethod,
    required this.onPaymentMethodAdded,
  });

  @override
  State<AddPaymentMethodWidget> createState() => _AddPaymentMethodWidgetState();
}

class _AddPaymentMethodWidgetState extends State<AddPaymentMethodWidget> {
  PaymentType? _selectedType;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.paymentMethod != null) {
      _selectedType = widget.paymentMethod!.type;
    }
  }

  void _onPaymentTypeSelected(PaymentType type) {
    setState(() => _selectedType = type);
  }

  void _onPaymentMethodSaved(PaymentMethod paymentMethod) async {
    setState(() => _isLoading = true);
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() => _isLoading = false);
    widget.onPaymentMethodAdded(paymentMethod);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        variant: AppBarVariant.standard,
        title: Text(widget.paymentMethod == null ? 'Add Payment Method' : 'Edit Payment Method'),
        showBackButton: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Payment type selection
                  if (widget.paymentMethod == null) ...[
                    Text(
                      'Select Payment Type',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    _buildPaymentTypeGrid(theme),
                    SizedBox(height: 3.h),
                  ],

                  // Payment form based on selected type
                  if (_selectedType != null || widget.paymentMethod != null)
                    _buildPaymentForm(theme),
                ],
              ),
            ),
    );
  }

  Widget _buildPaymentTypeGrid(ThemeData theme) {
    final paymentTypes = [
      {'type': PaymentType.creditCard, 'label': 'Credit Card'},
      {'type': PaymentType.debitCard, 'label': 'Debit Card'},
      {'type': PaymentType.upi, 'label': 'UPI'},
      {'type': PaymentType.netBanking, 'label': 'Net Banking'},
      {'type': PaymentType.wallet, 'label': 'Wallet'},
      {'type': PaymentType.cod, 'label': 'Cash on Delivery'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 3.w,
        mainAxisSpacing: 2.h,
      ),
      itemCount: paymentTypes.length,
      itemBuilder: (context, index) {
        final paymentType = paymentTypes[index];
        final type = paymentType['type'] as PaymentType;
        final label = paymentType['label'] as String;
        final isSelected = _selectedType == type;

        return InkWell(
          onTap: () => _onPaymentTypeSelected(type),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary.withValues(alpha: 0.1)
                  : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.dividerColor.withValues(alpha: 0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getPaymentTypeIcon(type),
                  size: 6.w,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                SizedBox(height: 1.h),
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentForm(ThemeData theme) {
    final paymentType = widget.paymentMethod?.type ?? _selectedType!;

    switch (paymentType) {
      case PaymentType.creditCard:
      case PaymentType.debitCard:
      case PaymentType.upi:
      case PaymentType.netBanking:
      case PaymentType.wallet:
        return _buildComingSoonForm(theme, paymentType);
      case PaymentType.cod:
        return _buildCodForm(theme);
    }
  }

  Widget _buildComingSoonForm(ThemeData theme, PaymentType paymentType) {
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
          Row(
            children: [
              Icon(
                _getPaymentTypeIcon(paymentType),
                color: theme.colorScheme.primary,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                _getPaymentTypeText(paymentType),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'This payment method is coming soon!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'We\'re working on adding this payment option. For now, please use Cash on Delivery or other available options.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodForm(ThemeData theme) {
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
          Row(
            children: [
              Icon(
                Icons.money,
                color: theme.colorScheme.primary,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Cash on Delivery',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'Pay when you receive your order. This option is available for all orders.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 3.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final paymentMethod = PaymentMethod(
                  id: widget.paymentMethod?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  type: PaymentType.cod,
                  isDefault: widget.paymentMethod?.isDefault ?? false,
                  isSaved: false,
                  createdAt: widget.paymentMethod?.createdAt ?? DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                _onPaymentMethodSaved(paymentMethod);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(vertical: 2.h),
              ),
              child: Text(
                widget.paymentMethod == null ? 'Add COD Option' : 'Update COD Option',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPaymentTypeIcon(PaymentType type) {
    switch (type) {
      case PaymentType.creditCard:
      case PaymentType.debitCard:
        return Icons.credit_card;
      case PaymentType.upi:
        return Icons.phone_android;
      case PaymentType.netBanking:
        return Icons.account_balance;
      case PaymentType.wallet:
        return Icons.wallet;
      case PaymentType.cod:
        return Icons.money;
    }
  }

  String _getPaymentTypeText(PaymentType type) {
    switch (type) {
      case PaymentType.creditCard:
        return 'Credit Card';
      case PaymentType.debitCard:
        return 'Debit Card';
      case PaymentType.upi:
        return 'UPI';
      case PaymentType.netBanking:
        return 'Net Banking';
      case PaymentType.wallet:
        return 'Wallet';
      case PaymentType.cod:
        return 'Cash on Delivery';
    }
  }
}

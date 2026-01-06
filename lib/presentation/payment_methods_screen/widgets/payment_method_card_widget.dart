import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../data/models/payment_model.dart';
import '../../../widgets/custom_icon_widget.dart';

class PaymentMethodCardWidget extends StatelessWidget {
  final PaymentMethod paymentMethod;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  const PaymentMethodCardWidget({
    super.key,
    required this.paymentMethod,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: paymentMethod.isDefault
              ? theme.colorScheme.primary
              : theme.dividerColor.withValues(alpha: 0.3),
          width: paymentMethod.isDefault ? 2 : 1,
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
          // Header with payment type icon
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            decoration: BoxDecoration(
              color: paymentMethod.isDefault
                  ? theme.colorScheme.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                _buildPaymentTypeIcon(theme),
                SizedBox(width: 2.w),
                Text(
                  _getPaymentTypeText(),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: paymentMethod.isDefault
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                if (paymentMethod.isDefault)
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

          // Payment method details
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Payment method specific details
                _buildPaymentMethodDetails(theme),

                // Last used info
                if (paymentMethod.lastUsed != null) ...[
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'schedule',
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        size: 3.w,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        'Last used: ${_formatDate(paymentMethod.lastUsed!)}',
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
                    if (!paymentMethod.isDefault && paymentMethod.isSaved)
                      TextButton.icon(
                        onPressed: onSetDefault,
                        icon: const Icon(Icons.star_border, size: 16),
                        label: const Text('Set as Default'),
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.primary,
                        ),
                      ),
                    const Spacer(),
                    if (paymentMethod.isSaved) ...[
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
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentTypeIcon(ThemeData theme) {
    IconData iconData;
    Color iconColor;

    switch (paymentMethod.type) {
      case PaymentType.creditCard:
      case PaymentType.debitCard:
        iconData = Icons.credit_card;
        iconColor = _getCardColor();
        break;
      case PaymentType.upi:
        iconData = Icons.phone_android;
        iconColor = Colors.green;
        break;
      case PaymentType.netBanking:
        iconData = Icons.account_balance;
        iconColor = Colors.blue;
        break;
      case PaymentType.wallet:
        iconData = Icons.wallet;
        iconColor = _getWalletColor();
        break;
      case PaymentType.cod:
        iconData = Icons.money;
        iconColor = Colors.orange;
        break;
    }

    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 4.w,
      ),
    );
  }

  Widget _buildPaymentMethodDetails(ThemeData theme) {
    switch (paymentMethod.type) {
      case PaymentType.creditCard:
      case PaymentType.debitCard:
        return _buildCardDetails(theme);
      case PaymentType.upi:
        return _buildUpiDetails(theme);
      case PaymentType.netBanking:
        return _buildNetBankingDetails(theme);
      case PaymentType.wallet:
        return _buildWalletDetails(theme);
      case PaymentType.cod:
        return _buildCodDetails(theme);
    }
  }

  Widget _buildCardDetails(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              paymentMethod.displayName,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 2.w),
            if (paymentMethod.cardType != null)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
                decoration: BoxDecoration(
                  color: _getCardColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  PaymentMethod.getCardTypeName(paymentMethod.cardType!),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: _getCardColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        if (paymentMethod.cardHolderName != null) ...[
          SizedBox(height: 0.5.h),
          Text(
            paymentMethod.cardHolderName!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
        if (paymentMethod.expiryDate != null) ...[
          SizedBox(height: 0.5.h),
          Text(
            'Expires: ${paymentMethod.expiryDate}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildUpiDetails(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          paymentMethod.upiId!,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          'Unified Payments Interface',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildNetBankingDetails(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          paymentMethod.bankName ?? 'Net Banking',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          'Internet Banking',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildWalletDetails(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              PaymentMethod.getWalletName(paymentMethod.walletType!),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (paymentMethod.walletNumber != null) ...[
              SizedBox(width: 2.w),
              Text(
                paymentMethod.walletNumber!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 0.5.h),
        Text(
          'Mobile Wallet',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildCodDetails(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cash on Delivery',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          'Pay when you receive your order',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Color _getCardColor() {
    switch (paymentMethod.cardType) {
      case CardType.visa:
        return Colors.blue;
      case CardType.mastercard:
        return Colors.red;
      case CardType.amex:
        return Colors.blue.shade700;
      case CardType.rupay:
        return Colors.orange;
      case CardType.discover:
        return Colors.orange.shade700;
      case CardType.maestro:
        return Colors.red.shade700;
      case CardType.unknown:
        return Colors.grey;
      case null:
        return Colors.grey;
    }
  }

  Color _getWalletColor() {
    switch (paymentMethod.walletType) {
      case WalletType.paytm:
        return Colors.blue.shade600;
      case WalletType.phonepe:
        return Colors.purple;
      case WalletType.googlePay:
        return Colors.green;
      case WalletType.amazonPay:
        return Colors.orange;
      case WalletType.mobikwik:
        return Colors.blue.shade800;
      case WalletType.airtelMoney:
        return Colors.red;
      case WalletType.freecharge:
        return Colors.purple.shade600;
      case WalletType.other:
        return Colors.grey;
      case null:
        return Colors.grey;
    }
  }

  String _getPaymentTypeText() {
    switch (paymentMethod.type) {
      case PaymentType.creditCard:
        return 'Credit Card';
      case PaymentType.debitCard:
        return 'Debit Card';
      case PaymentType.upi:
        return 'UPI';
      case PaymentType.netBanking:
        return 'Net Banking';
      case PaymentType.wallet:
        return PaymentMethod.getWalletName(paymentMethod.walletType!);
      case PaymentType.cod:
        return 'Cash on Delivery';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

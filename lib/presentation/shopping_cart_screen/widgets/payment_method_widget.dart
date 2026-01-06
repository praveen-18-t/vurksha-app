import 'package:flutter/material.dart';

/// Payment Method Widget
class PaymentMethodWidget extends StatelessWidget {
  final String? selectedPaymentMethod;
  final List<String> availableMethods;
  final Function(String)? onPaymentMethodChanged;

  const PaymentMethodWidget({
    super.key,
    this.selectedPaymentMethod,
    this.availableMethods = const [
      'UPI Payment',
      'Credit/Debit Card', 
      'Cash on Delivery',
    ],
    this.onPaymentMethodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text('Select your payment method'),
          const Text('Choose from UPI, Card, or Cash on Delivery'),
          ...availableMethods.map((method) => ListTile(
                title: Text(method),
                leading: const Icon(Icons.money),
                onTap: () {
                  onPaymentMethodChanged?.call(method);
                },
                selected: selectedPaymentMethod == method,
              )),
        ],
      ),
    );
  }
}

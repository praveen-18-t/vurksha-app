import 'package:flutter/material.dart';

import '../../data/models/payment_model.dart';
import '../../widgets/custom_app_bar.dart';
import 'widgets/payment_methods_list_widget.dart';
import 'widgets/add_payment_method_widget.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  List<PaymentMethod> _paymentMethods = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _paymentMethods = _getMockPaymentMethods();
      _isLoading = false;
    });
  }

  List<PaymentMethod> _getMockPaymentMethods() {
    return [
      PaymentMethod(
        id: '1',
        type: PaymentType.creditCard,
        cardNumber: '4242424242424242',
        cardHolderName: 'John Doe',
        expiryDate: '12/25',
        cardType: CardType.visa,
        isDefault: true,
        isSaved: true,
        token: 'token_123',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
        lastUsed: DateTime.now().subtract(const Duration(days: 1)),
      ),
      PaymentMethod(
        id: '2',
        type: PaymentType.upi,
        upiId: 'john.doe@paytm',
        isDefault: false,
        isSaved: true,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        lastUsed: DateTime.now().subtract(const Duration(days: 3)),
      ),
      PaymentMethod(
        id: '3',
        type: PaymentType.wallet,
        walletType: WalletType.phonepe,
        walletNumber: '9876543210',
        isDefault: false,
        isSaved: true,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      PaymentMethod(
        id: '4',
        type: PaymentType.cod,
        isDefault: false,
        isSaved: false,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }

  
  void _onAddPaymentMethod() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPaymentMethodWidget(
          onPaymentMethodAdded: (paymentMethod) => _addPaymentMethod(paymentMethod),
        ),
      ),
    ).then((_) => _loadData());
  }

  void _onEditPaymentMethod(PaymentMethod paymentMethod) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPaymentMethodWidget(
          paymentMethod: paymentMethod,
          onPaymentMethodAdded: (updatedMethod) => _updatePaymentMethod(updatedMethod),
        ),
      ),
    ).then((_) => _loadData());
  }

  void _onDeletePaymentMethod(String paymentMethodId) {
    setState(() {
      _paymentMethods.removeWhere((method) => method.id == paymentMethodId);
    });
    _showSnackBar('Payment method deleted successfully');
  }

  void _onSetDefault(String paymentMethodId) {
    setState(() {
      _paymentMethods = _paymentMethods.map((method) {
        return method.copyWith(
          isDefault: method.id == paymentMethodId,
          updatedAt: DateTime.now(),
        );
      }).toList();
    });
    _showSnackBar('Default payment method updated');
  }

  Future<void> _addPaymentMethod(PaymentMethod paymentMethod) async {
    setState(() => _isLoading = true);
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _paymentMethods.add(paymentMethod);
      _isLoading = false;
    });
    
    _showSnackBar('Payment method added successfully');
  }

  Future<void> _updatePaymentMethod(PaymentMethod paymentMethod) async {
    setState(() => _isLoading = true);
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      final index = _paymentMethods.indexWhere((method) => method.id == paymentMethod.id);
      if (index >= 0) {
        _paymentMethods[index] = paymentMethod;
      }
      _isLoading = false;
    });
    
    _showSnackBar('Payment method updated successfully');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        variant: AppBarVariant.standard,
        title: const Text('Payment Methods'),
        showBackButton: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : PaymentMethodsListWidget(
              paymentMethods: _paymentMethods,
              onAddPaymentMethod: _onAddPaymentMethod,
              onEditPaymentMethod: _onEditPaymentMethod,
              onDeletePaymentMethod: _onDeletePaymentMethod,
              onSetDefault: _onSetDefault,
            ),
    );
  }
}

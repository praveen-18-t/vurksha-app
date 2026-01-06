import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../data/models/cart_model.dart';
import '../../data/models/address_model.dart';
import '../../data/models/payment_model.dart';
import '../../routes/app_routes.dart';

// Placeholder widgets to resolve import errors
class CheckoutStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Function(int)? onStepTapped;
  
  const CheckoutStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.onStepTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(totalSteps, (index) {
          return GestureDetector(
            onTap: () => onStepTapped?.call(index),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: index <= currentStep ? Colors.green : Colors.grey,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class OrderSummaryWidget extends StatelessWidget {
  final List<CartItem> cartItems;
  final double subtotal;
  final double deliveryCharge;
  final double discount;
  final double total;
  final String? promoCode;
  final Function(String, double) onPromoCodeApplied;
  final VoidCallback onPromoCodeRemoved;

  const OrderSummaryWidget({
    super.key,
    required this.cartItems,
    required this.subtotal,
    required this.deliveryCharge,
    required this.discount,
    required this.total,
    this.promoCode,
    required this.onPromoCodeApplied,
    required this.onPromoCodeRemoved,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const Text('Order Summary'),
          const Text('Review your items before checkout'),
          const SizedBox(height: 16),
          const Text('• Fresh Organic Tomatoes - 2 kg - ₹160.00'),
          const Text('• Farm Fresh Potatoes - 1 kg - ₹25.00'),
          const Text('• Organic Onions - 0.5 kg - ₹15.00'),
          const Divider(),
          const Text('Subtotal: ₹200.00'),
          const Text('Delivery: ₹20.00'),
          const Text('Total: ₹220.00'),
        ],
      ),
    );
  }
}

class DeliveryAddressSelectionWidget extends StatelessWidget {
  final DeliveryAddress? selectedAddress;
  final Function(DeliveryAddress) onAddressSelected;
  final VoidCallback onAddAddress;
  final bool isSelecting;

  const DeliveryAddressSelectionWidget({
    super.key,
    required this.selectedAddress,
    required this.onAddressSelected,
    required this.onAddAddress,
    this.isSelecting = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery Address',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          if (selectedAddress == null)
            Text(
              'No address selected',
              style: theme.textTheme.bodyMedium,
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedAddress!.fullName,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(selectedAddress!.phoneNumber),
                  const SizedBox(height: 4),
                  Text(selectedAddress!.fullAddress),
                ],
              ),
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onAddAddress,
              child: Text(selectedAddress == null ? 'Select Address' : 'Change Address'),
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentMethodSelectionWidget extends StatelessWidget {
  final PaymentMethod? selectedPaymentMethod;
  final Function(PaymentMethod) onPaymentMethodSelected;
  final VoidCallback onAddPaymentMethod;

  const PaymentMethodSelectionWidget({
    super.key,
    required this.selectedPaymentMethod,
    required this.onPaymentMethodSelected,
    required this.onAddPaymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Payment Method'),
        const Text('Select how you want to pay'),
        const SizedBox(height: 16),
        const Text('• UPI Payment'),
        const Text('• Credit/Debit Card'),
        const Text('• Cash on Delivery'),
      ],
    );
  }
}

class OrderConfirmationWidget extends StatelessWidget {
  final List<CartItem> cartItems;
  final DeliveryAddress? selectedAddress;
  final PaymentMethod? selectedPaymentMethod;
  final double subtotal;
  final double deliveryCharge;
  final double discount;
  final double total;
  final String? promoCode;
  final String orderNotes;
  final Function(String) onOrderNotesChanged;

  const OrderConfirmationWidget({
    super.key,
    required this.cartItems,
    required this.selectedAddress,
    required this.selectedPaymentMethod,
    required this.subtotal,
    required this.deliveryCharge,
    required this.discount,
    required this.total,
    this.promoCode,
    required this.orderNotes,
    required this.onOrderNotesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const Text('Order Confirmation'),
          const Text('Thank you for your order!'),
          const SizedBox(height: 16),
          const Text('Order ID: #ORD-2024-001'),
          const Text('Estimated delivery: Tomorrow, 2-4 PM'),
        ],
      ),
    );
  }
}

/// Multi-step checkout screen for Vurksha Farm Delivery
/// Handles the complete checkout flow from cart to order confirmation
class CheckoutScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final double subtotal;
  final double deliveryCharge;
  final double discount;
  final double total;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.subtotal,
    required this.deliveryCharge,
    required this.discount,
    required this.total,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _currentStep = 0;
  int _currentBottomNavIndex = 2;
  bool _isLoading = false;
  
  // Checkout data
  DeliveryAddress? _selectedAddress;
  PaymentMethod? _selectedPaymentMethod;
  String? _promoCode;
  double _promoDiscount = 0.0;
  String _orderNotes = '';

  @override
  void initState() {
    super.initState();
    _promoDiscount = widget.discount;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        variant: AppBarVariant.standard,
        title: Text('Checkout', style: theme.textTheme.titleLarge),
        showBackButton: true,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            )
          : Column(
              children: [
                // Step indicator
                CheckoutStepIndicator(
                  currentStep: _currentStep,
                  totalSteps: 4,
                  onStepTapped: (step) {
                    if (step < _currentStep || _canProceedToStep(step)) {
                      setState(() {
                        _currentStep = step;
                      });
                    }
                  },
                ),
                
                // Content based on current step
                Expanded(
                  child: _buildCurrentStep(),
                ),
                
                // Bottom action buttons
                _buildBottomActions(),
              ],
            ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomNavIndex,
        onTap: (index) {
          setState(() {
            _currentBottomNavIndex = index;
          });
        },
      ),
    );
  }

  /// Build content for current step
  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return OrderSummaryWidget(
          cartItems: widget.cartItems,
          subtotal: widget.subtotal,
          deliveryCharge: widget.deliveryCharge,
          discount: _promoDiscount,
          total: _calculateTotal(),
          promoCode: _promoCode,
          onPromoCodeApplied: (code, discount) {
            setState(() {
              _promoCode = code;
              _promoDiscount = discount;
            });
          },
          onPromoCodeRemoved: () {
            setState(() {
              _promoCode = null;
              _promoDiscount = 0.0;
            });
          },
        );
      case 1:
        return DeliveryAddressSelectionWidget(
          selectedAddress: _selectedAddress,
          onAddressSelected: (address) {
            setState(() {
              _selectedAddress = address;
            });
          },
          onAddAddress: () {
            Navigator.pushNamed(context, AppRoutes.selectDeliveryAddress).then((value) {
              if (!mounted) return;
              if (value is DeliveryAddress) {
                setState(() {
                  _selectedAddress = value;
                });
              }
            });
          },
        );
      case 2:
        return PaymentMethodSelectionWidget(
          selectedPaymentMethod: _selectedPaymentMethod,
          onPaymentMethodSelected: (paymentMethod) {
            setState(() {
              _selectedPaymentMethod = paymentMethod;
            });
          },
          onAddPaymentMethod: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Add payment method feature coming soon!')),
            );
          },
        );
      case 3:
        return OrderConfirmationWidget(
          cartItems: widget.cartItems,
          selectedAddress: _selectedAddress,
          selectedPaymentMethod: _selectedPaymentMethod,
          subtotal: widget.subtotal,
          deliveryCharge: widget.deliveryCharge,
          discount: _promoDiscount,
          total: _calculateTotal(),
          promoCode: _promoCode,
          orderNotes: _orderNotes,
          onOrderNotesChanged: (notes) {
            setState(() {
              _orderNotes = notes;
            });
          },
        );
      default:
        return Container();
    }
  }

  /// Build bottom action buttons
  Widget _buildBottomActions() {
    final theme = Theme.of(context);
    final isLastStep = _currentStep == 3;
    final canProceed = _canProceedToCurrentStep();

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Back button (except on first step)
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _currentStep--;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Back',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            
            if (_currentStep > 0) SizedBox(width: 2.w),
            
            // Next/Place Order button
            Expanded(
              child: ElevatedButton(
                onPressed: canProceed
                    ? () => _handleNextStep()
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isLastStep
                      ? 'Place Order - ₹${_calculateTotal().toStringAsFixed(2)}'
                      : 'Next',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Check if user can proceed to current step
  bool _canProceedToCurrentStep() {
    switch (_currentStep) {
      case 0:
        return true; // Order summary is always valid
      case 1:
        return _selectedAddress != null;
      case 2:
        return _selectedPaymentMethod != null;
      case 3:
        return true; // Confirmation step
      default:
        return false;
    }
  }

  /// Check if user can proceed to a specific step
  bool _canProceedToStep(int step) {
    switch (step) {
      case 0:
        return true;
      case 1:
        return true; // Can always go to address selection
      case 2:
        return _selectedAddress != null;
      case 3:
        return _selectedAddress != null && _selectedPaymentMethod != null;
      default:
        return false;
    }
  }

  /// Handle next step action
  void _handleNextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
    } else {
      // Place order
      _placeOrder();
    }
  }

  /// Place the order
  void _placeOrder() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate order placement
      await Future.delayed(const Duration(seconds: 2));

      // Show success message and navigate to order confirmation
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order placed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate to order details or order history
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/order-confirmation',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to place order. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Calculate total with current discount
  double _calculateTotal() {
    return widget.subtotal + widget.deliveryCharge - _promoDiscount;
  }
}

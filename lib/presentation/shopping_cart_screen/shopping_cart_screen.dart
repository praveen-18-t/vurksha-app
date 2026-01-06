import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../data/models/cart_model.dart';
import './widgets/cart_item_card_widget.dart';
import './widgets/empty_cart_widget.dart';
import './widgets/order_summary_widget.dart';
import './widgets/promo_code_widget.dart';

/// Shopping Cart Screen for Vurksha Farm Delivery
/// Manages cart items with quantity adjustments, swipe-to-delete, and checkout
class ShoppingCartScreen extends StatefulWidget {
  const ShoppingCartScreen({super.key});

  @override
  State<ShoppingCartScreen> createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  int _currentBottomNavIndex = 2; // Cart tab
  bool _isEditMode = false;
  bool _isLoading = false;
  bool _showPromoCode = false;
  String? _appliedPromoCode;
  double _promoDiscount = 0.0;

  // Mock cart data with realistic organic products
  final List<CartItem> _cartItems = [
    CartItem(
      id: "cart_001",
      name: "Organic Tomatoes",
      description: "Fresh organic tomatoes from local farms",
      pricePerUnit: 80.0,
      quantity: 2,
      unit: "kg",
      imageUrl: "https://images.unsplash.com/photo-1678272684266-b980500f327b",
      stockAvailable: 50,
      tags: ["organic", "vegetable", "fresh"],
      addedAt: DateTime.now(),
    ),
    CartItem(
      id: "cart_002",
      name: "Fresh Spinach",
      description: "Organic spinach leaves, rich in nutrients",
      pricePerUnit: 40.0,
      quantity: 1,
      unit: "g",
      imageUrl: "https://images.unsplash.com/photo-1583681781586-b980500f327a",
      stockAvailable: 30,
      tags: ["organic", "leafy-green", "fresh"],
      addedAt: DateTime.now(),
    ),
    CartItem(
      id: "cart_003",
      name: "Organic Carrots",
      description: "Fresh organic carrots, rich in vitamin A",
      pricePerUnit: 60.0,
      quantity: 1,
      unit: "kg",
      imageUrl: "https://images.unsplash.com/photo-1671193237723-8668a0156277",
      stockAvailable: 40,
      tags: ["organic", "vegetable", "root"],
      addedAt: DateTime.now(),
    ),
  ];

  // Free delivery threshold
  final double _freeDeliveryThreshold = 500.0;
  final double _deliveryCharge = 40.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        variant: AppBarVariant.standard,
        title: Text('Cart', style: theme.textTheme.titleLarge),
        actions: [
          if (_cartItems.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditMode = !_isEditMode;
                });
              },
              child: Text(
                _isEditMode ? 'Done' : 'Edit',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            )
          : _cartItems.isEmpty
          ? EmptyCartWidget(
              onBrowseCategories: () {
                Navigator.pushNamed(context, '/category-listing-screen');
              },
            )
          : RefreshIndicator(
              onRefresh: _refreshCart,
              color: theme.colorScheme.primary,
              child: Column(
                children: [
                  // Cart items list
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 2.h,
                      ),
                      itemCount: _cartItems.length,
                      itemBuilder: (context, index) {
                        final item = _cartItems[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: 2.h),
                          child: Slidable(
                            key: ValueKey(item.id),
                            endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (context) {
                                    _deleteCartItem(index);
                                  },
                                  backgroundColor: theme.colorScheme.error,
                                  foregroundColor: theme.colorScheme.onError,
                                  icon: Icons.delete_outline,
                                  label: 'Delete',
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ],
                            ),
                            child: CartItemCardWidget(
                              item: item,
                              isEditMode: _isEditMode,
                              onQuantityChanged: (newQuantity) {
                                _updateQuantity(index, newQuantity);
                              },
                              onDelete: () {
                                _deleteCartItem(index);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Promo code section
                  if (_showPromoCode)
                    PromoCodeWidget(
                      onApply: _applyPromoCode,
                      appliedCode: _appliedPromoCode,
                      onRemove: () {
                        setState(() {
                          _appliedPromoCode = null;
                          _promoDiscount = 0.0;
                        });
                      },
                    ),

                  // Order summary
                  OrderSummaryWidget(
                    subtotal: _calculateSubtotal(),
                    deliveryCharge: _calculateDeliveryCharge(),
                    discount: _promoDiscount,
                    total: _calculateTotal(),
                    freeDeliveryThreshold: _freeDeliveryThreshold,
                    onTogglePromoCode: () {
                      setState(() {
                        _showPromoCode = !_showPromoCode;
                      });
                    },
                    showPromoCode: _showPromoCode,
                  ),

                  // Checkout button
                  Container(
                    width: double.infinity,
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
                      child: ElevatedButton(
                        onPressed: _cartItems.isEmpty
                            ? null
                            : _proceedToCheckout,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Proceed to Checkout - ₹${_calculateTotal().toStringAsFixed(2)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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

  /// Calculate subtotal of all cart items
  double _calculateSubtotal() {
    return _cartItems.fold(0.0, (sum, item) {
      return sum + (item.pricePerUnit * item.quantity);
    });
  }

  /// Calculate delivery charge based on subtotal
  double _calculateDeliveryCharge() {
    final subtotal = _calculateSubtotal();
    return subtotal >= _freeDeliveryThreshold ? 0.0 : _deliveryCharge;
  }

  /// Calculate total amount including delivery and discount
  double _calculateTotal() {
    final subtotal = _calculateSubtotal();
    final delivery = _calculateDeliveryCharge();
    return subtotal + delivery - _promoDiscount;
  }

  /// Update quantity of cart item
  void _updateQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      _deleteCartItem(index);
      return;
    }

    final item = _cartItems[index];
    final stockAvailable = item.stockAvailable;

    if (newQuantity > stockAvailable) {
      _showSnackBar(
        'Only $stockAvailable ${item.unit} available in stock',
        isError: true,
      );
      return;
    }

    setState(() {
      _cartItems[index] = _cartItems[index].copyWith(quantity: newQuantity);
    });

    _showSnackBar('Quantity updated');
  }

  /// Delete cart item with confirmation
  void _deleteCartItem(int index) {
    final item = _cartItems[index];

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Text('Remove Item', style: theme.textTheme.titleLarge),
          content: Text(
            'Remove ${item.name} from cart?',
            style: theme.textTheme.bodyLarge,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _cartItems.removeAt(index);
                });
                _showSnackBar('${item.name} removed from cart');
              },
              child: Text(
                'Remove',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Refresh cart data
  Future<void> _refreshCart() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call to sync cart
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });

    _showSnackBar('Cart updated');
  }

  /// Apply promo code
  void _applyPromoCode(String code) {
    // Mock promo code validation
    final validCodes = {
      'FRESH10': 0.10, // 10% discount
      'ORGANIC20': 0.20, // 20% discount
      'WELCOME50': 50.0, // ₹50 flat discount
    };

    if (validCodes.containsKey(code.toUpperCase())) {
      final discountValue = validCodes[code.toUpperCase()]!;
      final subtotal = _calculateSubtotal();

      setState(() {
        _appliedPromoCode = code.toUpperCase();
        // If discount is less than 1, it's a percentage
        _promoDiscount = discountValue < 1
            ? subtotal * discountValue
            : discountValue;
      });

      _showSnackBar('Promo code applied successfully!');
    } else {
      _showSnackBar('Invalid promo code', isError: true);
    }
  }

  /// Proceed to checkout
  void _proceedToCheckout() {
    if (_cartItems.isEmpty) {
      _showSnackBar('Your cart is empty', isError: true);
      return;
    }

    // Navigate to checkout screen (placeholder)
    _showSnackBar('Proceeding to checkout...');

    // In real implementation, navigate to checkout screen
    // Navigator.pushNamed(context, '/checkout-screen');
  }

  /// Show snackbar message
  void _showSnackBar(String message, {bool isError = false}) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: isError
            ? theme.colorScheme.error
            : theme.colorScheme.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(4.w),
      ),
    );
  }
}

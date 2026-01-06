import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_model.dart';

// State class for the cart
class CartState {
  final List<CartItem> items;
  final double subtotal;
  final double deliveryCharge;
  final double total;
  final double discount;
  final String? appliedCoupon;
  final bool isLoading;
  final String? errorMessage;

  CartState({
    required this.items,
    required this.subtotal,
    required this.deliveryCharge,
    required this.total,
    this.discount = 0.0,
    this.appliedCoupon,
    this.isLoading = false,
    this.errorMessage,
  });

  // Initial state
  factory CartState.initial() {
    return CartState(
      items: [],
      subtotal: 0.0,
      deliveryCharge: 0.0,
      total: 0.0,
    );
  }

  // CopyWith method to create a new state from the existing one
  CartState copyWith({
    List<CartItem>? items,
    double? subtotal,
    double? deliveryCharge,
    double? total,
    double? discount,
    String? appliedCoupon,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CartState(
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      deliveryCharge: deliveryCharge ?? this.deliveryCharge,
      total: total ?? this.total,
      discount: discount ?? this.discount,
      appliedCoupon: appliedCoupon ?? this.appliedCoupon,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// StateNotifier for the cart
class CartNotifier extends StateNotifier<CartState> {
  final double _freeDeliveryThreshold = 500.0;
  final double _deliveryCharge = 40.0;

  // Mock coupon data
  final Map<String, double> _coupons = {
    'WELCOME10': 10.0,
    'SAVE20': 20.0,
    'FLAT50': 50.0,
  };

  CartNotifier() : super(CartState.initial()) {
    _loadCartFromStorage();
  }

  // Load cart data from SharedPreferences
  Future<void> _loadCartFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString('cart_data');
      final couponJson = prefs.getString('applied_coupon');
      
      if (cartJson != null) {
        final cartData = json.decode(cartJson) as List;
        final items = cartData.map((item) => CartItem.fromJson(item)).toList();
        state = state.copyWith(items: items);
        
        if (couponJson != null) {
          final couponData = json.decode(couponJson) as Map<String, dynamic>;
          state = state.copyWith(
            appliedCoupon: couponData['code'],
            discount: couponData['discount'],
          );
        }
        
        _recalculateTotals();
      } else {
        // Start with empty cart - no sample data
        state = CartState.initial();
        _recalculateTotals();
      }
    } catch (e) {
      // If loading fails, start with empty cart
      state = CartState.initial();
      _recalculateTotals();
    }
  }

  // Save cart data to SharedPreferences
  Future<void> _saveCartToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = json.encode(state.items.map((item) => item.toJson()).toList());
      await prefs.setString('cart_data', cartJson);
      
      if (state.appliedCoupon != null) {
        final couponJson = json.encode({
          'code': state.appliedCoupon,
          'discount': state.discount,
        });
        await prefs.setString('applied_coupon', couponJson);
      } else {
        await prefs.remove('applied_coupon');
      }
    } catch (e) {
      // Handle save error silently for now
    }
  }

  void _recalculateTotals() {
    final subtotal = state.items.fold(0.0, (sum, item) => sum + (item.pricePerUnit * item.quantity));
    final discountAmount = state.discount;
    final taxableAmount = subtotal - discountAmount;
    final deliveryCharge = subtotal >= _freeDeliveryThreshold ? 0.0 : _deliveryCharge;
    final total = taxableAmount + deliveryCharge;

    state = state.copyWith(
      subtotal: subtotal,
      discount: discountAmount,
      deliveryCharge: deliveryCharge,
      total: total,
    );
    
    // Save to storage after recalculation
    _saveCartToStorage();
  }

  void updateQuantity(String itemId, int newQuantity) {
    final updatedItems = state.items.map((item) {
      if (item.id == itemId) {
        if (newQuantity > 0 && newQuantity <= item.stockAvailable) {
          item.quantity = newQuantity;
        }
      }
      return item;
    }).toList();

    state = state.copyWith(items: updatedItems);
    _recalculateTotals();
  }

  void removeItem(String itemId) {
    final updatedItems = state.items.where((item) => item.id != itemId).toList();
    state = state.copyWith(items: updatedItems);
    _recalculateTotals();
  }

  // Add item to cart
  void addItem(CartItem item) {
    final existingItemIndex = state.items.indexWhere((i) => i.id == item.id);
    
    if (existingItemIndex != -1) {
      // Item exists, update quantity
      final updatedItems = List<CartItem>.from(state.items);
      updatedItems[existingItemIndex] = updatedItems[existingItemIndex].copyWith(
        quantity: updatedItems[existingItemIndex].quantity + item.quantity,
      );
      state = state.copyWith(items: updatedItems);
    } else {
      // New item, add to list
      state = state.copyWith(items: [...state.items, item]);
    }
    _recalculateTotals();
  }

  // Apply coupon code
  Future<void> applyCoupon(String couponCode) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));
      
      final upperCaseCode = couponCode.toUpperCase();
      if (_coupons.containsKey(upperCaseCode)) {
        final discountAmount = _coupons[upperCaseCode]!;
        state = state.copyWith(
          appliedCoupon: upperCaseCode,
          discount: discountAmount,
          isLoading: false,
        );
        _recalculateTotals();
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Invalid coupon code',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to apply coupon',
      );
    }
  }

  // Remove coupon
  void removeCoupon() {
    state = state.copyWith(
      appliedCoupon: null,
      discount: 0.0,
      errorMessage: null,
    );
    _recalculateTotals();
  }
  // Clear cart data
  void clearCart() {
    state = CartState.initial();
    _saveCartToStorage();
  }

  // Sync cart with server (mock implementation)
  Future<void> syncWithServer() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // In a real app, this would sync with backend
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to sync cart',
      );
    }
  }
}

// Provider for the CartNotifier
final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});

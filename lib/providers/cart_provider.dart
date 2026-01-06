import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/api/api_client.dart';
import '../core/api/api_config.dart';
import '../data/models/product_model.dart';

class CartItem {
  final String productId;
  final String name;
  final double price;
  final String image;
  int quantity;
  final String unit;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.image,
    this.quantity = 1,
    this.unit = 'kg',
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'] as String,
      name: json['productName'] as String,
      price: (json['unitPrice'] as num).toDouble(),
      image: json['productImage'] as String? ?? '',
      quantity: json['quantity'] as int,
      unit: json['unit'] as String? ?? 'kg',
    );
  }
}

class CartProvider with ChangeNotifier {
  final ApiClient _client = ApiClient.instance;
  List<CartItem> _items = [];
  double _totalAmount = 0.0;
  bool _isLoading = false;

  List<CartItem> get items => List.unmodifiable(_items);
  double get totalAmount => _totalAmount;
  bool get isLoading => _isLoading;
  int get itemCount => _items.fold<int>(0, (sum, item) => sum + item.quantity);

  CartProvider() {
    _loadCart();
  }

  /// Load cart from backend
  Future<void> _loadCart() async {
    if (!await _client.isAuthenticated()) return;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _client.get(ApiConfig.cartEndpoint);

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (data) => data['cart'] as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        final cartData = apiResponse.data!;
        final itemsList = cartData['items'] as List<dynamic>;

        _items = itemsList
            .map((json) => CartItem.fromJson(json as Map<String, dynamic>))
            .toList();

        _totalAmount = (cartData['subtotal'] as num).toDouble();
      }
    } catch (e) {
      debugPrint('Error loading cart: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add item to cart
  Future<void> addItem({
    required String productId,
    required String name,
    required double price,
    required String image,
    int quantity = 1,
  }) async {
    // Optimistic update
    final existingIndex = _items.indexWhere((i) => i.productId == productId);
    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(
        CartItem(
          productId: productId,
          name: name,
          price: price,
          image: image,
          quantity: quantity,
        ),
      );
    }
    _calculateTotal();
    notifyListeners();

    // Sync with backend
    try {
      await _client.post(
        '${ApiConfig.cartEndpoint}/items',
        data: {
          'productId': productId,
          'productName': name,
          'productImage': image,
          'unitPrice': price,
          'quantity': quantity,
        },
      );
    } catch (e) {
      // Revert on failure
      debugPrint('Failed to add item: $e');
      _loadCart(); // Reload to sync state
    }
  }

  /// Update item quantity
  Future<void> updateQuantity(String productId, int quantity) async {
    if (quantity < 0) return;

    // Optimistic update
    final index = _items.indexWhere((i) => i.productId == productId);
    if (index == -1) return;

    if (quantity == 0) {
      _items.removeAt(index);
    } else {
      _items[index].quantity = quantity;
    }
    _calculateTotal();
    notifyListeners();

    // Sync with backend
    try {
      if (quantity == 0) {
        await _client.delete('${ApiConfig.cartEndpoint}/items/$productId');
      } else {
        await _client.put(
          '${ApiConfig.cartEndpoint}/items/$productId',
          data: {'quantity': quantity},
        );
      }
    } catch (e) {
      debugPrint('Failed to update quantity: $e');
      _loadCart();
    }
  }

  /// Clear cart
  Future<void> clear() async {
    _items.clear();
    _totalAmount = 0;
    notifyListeners();

    try {
      await _client.delete(ApiConfig.cartEndpoint);
    } catch (e) {
      debugPrint('Failed to clear cart: $e');
    }
  }

  void _calculateTotal() {
    _totalAmount = _items.fold(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }
}

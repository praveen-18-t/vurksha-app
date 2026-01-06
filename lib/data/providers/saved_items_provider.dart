import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cart_model.dart';

// Saved item model (same as CartItem but for saved items)
class SavedItem {
  final String id;
  final String name;
  final double pricePerUnit;
  final String unit;
  final String image;
  final DateTime savedDate;

  SavedItem({
    required this.id,
    required this.name,
    required this.pricePerUnit,
    required this.unit,
    required this.image,
    required this.savedDate,
  });

  // Convert from CartItem
  factory SavedItem.fromCartItem(CartItem cartItem) {
    return SavedItem(
      id: cartItem.id,
      name: cartItem.name,
      pricePerUnit: cartItem.pricePerUnit,
      unit: cartItem.unit,
      image: cartItem.imageUrl,
      savedDate: DateTime.now(),
    );
  }

  // Convert to CartItem
  CartItem toCartItem() {
    return CartItem(
      id: id,
      name: name,
      description: "Saved item restored to cart",
      pricePerUnit: pricePerUnit,
      quantity: 1, // Default quantity when restored
      unit: unit,
      imageUrl: image,
      stockAvailable: 999, // High stock for saved items
      tags: [],
      addedAt: DateTime.now(),
    );
  }
}

// State for saved items
class SavedItemsState {
  final List<SavedItem> items;
  final bool isLoading;

  SavedItemsState({
    required this.items,
    this.isLoading = false,
  });

  SavedItemsState copyWith({
    List<SavedItem>? items,
    bool? isLoading,
  }) {
    return SavedItemsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
    );
  }
  
  // Getter for saved items
  List<SavedItem> get savedItems => items;
}

// Notifier for saved items
class SavedItemsNotifier extends StateNotifier<SavedItemsState> {
  SavedItemsNotifier() : super(SavedItemsState(items: []));

  // Save item for later
  void saveForLater(CartItem cartItem) {
    final savedItem = SavedItem.fromCartItem(cartItem);
    final updatedItems = [savedItem, ...state.items];
    state = state.copyWith(items: updatedItems);
  }

  // Remove saved item
  void removeSavedItem(String itemId) {
    final updatedItems = state.items.where((item) => item.id != itemId).toList();
    state = state.copyWith(items: updatedItems);
  }

  // Restore saved item to cart
  CartItem restoreToCart(String itemId) {
    final savedItem = state.savedItems.firstWhere((item) => item.id == itemId);
    removeSavedItem(itemId);
    return savedItem.toCartItem();
  }

  // Get all saved items
  List<SavedItem> get savedItems => state.savedItems;
}

// Provider for saved items
final savedItemsProvider = StateNotifierProvider<SavedItemsNotifier, SavedItemsState>((ref) {
  return SavedItemsNotifier();
});

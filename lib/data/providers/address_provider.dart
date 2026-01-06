import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../notifications/notification_controller.dart';
import '../models/address_model.dart';
import '../repositories/address_repository.dart';

final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AddressRepository(prefs: prefs);
});

class AddressState {
  const AddressState({
    required this.addresses,
    required this.isLoading,
    this.errorMessage,
  });

  final List<DeliveryAddress> addresses;
  final bool isLoading;
  final String? errorMessage;

  AddressState copyWith({
    List<DeliveryAddress>? addresses,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AddressState(
      addresses: addresses ?? this.addresses,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  factory AddressState.initial() {
    return const AddressState(addresses: <DeliveryAddress>[], isLoading: true);
  }
}

class AddressNotifier extends StateNotifier<AddressState> {
  AddressNotifier({required AddressRepository repository})
      : _repository = repository,
        super(AddressState.initial()) {
    _load();
  }

  final AddressRepository _repository;

  Future<void> _load() async {
    try {
      final addresses = await _repository.getAddresses();
      state = state.copyWith(addresses: addresses, isLoading: false, errorMessage: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await _load();
  }

  Future<void> addOrUpdate(DeliveryAddress address) async {
    final existingIndex = state.addresses.indexWhere((a) => a.id == address.id);

    List<DeliveryAddress> updated;
    if (existingIndex >= 0) {
      updated = [...state.addresses];
      updated[existingIndex] = address;
    } else {
      updated = [...state.addresses, address];
    }

    if (address.isDefault) {
      updated = _setDefaultInList(updated, address.id);
    }

    state = state.copyWith(addresses: updated);
    await _repository.saveAddresses(updated);
  }

  Future<void> deleteById(String id) async {
    final updated = state.addresses.where((a) => a.id != id).toList();
    state = state.copyWith(addresses: updated);
    await _repository.saveAddresses(updated);
  }

  Future<void> setDefault(String id) async {
    final updated = _setDefaultInList(state.addresses, id);
    state = state.copyWith(addresses: updated);
    await _repository.saveAddresses(updated);
  }

  List<DeliveryAddress> _setDefaultInList(List<DeliveryAddress> addresses, String defaultId) {
    return addresses
        .map((a) => a.copyWith(isDefault: a.id == defaultId, updatedAt: DateTime.now()))
        .toList();
  }
}

final addressProvider = StateNotifierProvider<AddressNotifier, AddressState>((ref) {
  final repo = ref.watch(addressRepositoryProvider);
  return AddressNotifier(repository: repo);
});

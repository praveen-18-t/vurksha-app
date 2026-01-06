import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/address_model.dart';
import '../models/payment_method.dart';

class CheckoutState {
  final int currentStep;
  final DeliveryAddress? selectedAddress;
  final PaymentMethod? selectedPaymentMethod;
  final String orderNotes;
  final bool isLoading;

  CheckoutState({
    this.currentStep = 0,
    this.selectedAddress,
    this.selectedPaymentMethod,
    this.orderNotes = '',
    this.isLoading = false,
  });

  CheckoutState copyWith({
    int? currentStep,
    DeliveryAddress? selectedAddress,
    PaymentMethod? selectedPaymentMethod,
    String? orderNotes,
    bool? isLoading,
  }) {
    return CheckoutState(
      currentStep: currentStep ?? this.currentStep,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      selectedPaymentMethod: selectedPaymentMethod ?? this.selectedPaymentMethod,
      orderNotes: orderNotes ?? this.orderNotes,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class CheckoutNotifier extends StateNotifier<CheckoutState> {
  CheckoutNotifier() : super(CheckoutState());

  void nextStep() {
    if (state.currentStep < 3) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void setStep(int step) {
    if (step >= 0 && step <= 3) {
      state = state.copyWith(currentStep: step);
    }
  }

  void selectAddress(DeliveryAddress address) {
    state = state.copyWith(selectedAddress: address);
  }

  void selectPaymentMethod(PaymentMethod paymentMethod) {
    state = state.copyWith(selectedPaymentMethod: paymentMethod);
  }

  void updateOrderNotes(String notes) {
    state = state.copyWith(orderNotes: notes);
  }

  Future<void> placeOrder() async {
    state = state.copyWith(isLoading: true);
    // Simulate network request
    await Future.delayed(const Duration(seconds: 2));
    // Handle order placement logic here
    state = state.copyWith(isLoading: false);
  }
}

final checkoutProvider = StateNotifierProvider<CheckoutNotifier, CheckoutState>((ref) {
  return CheckoutNotifier();
});

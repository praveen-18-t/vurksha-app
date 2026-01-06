import '../models/delivery_model.dart';

class DeliveryRepository {
  // Mock database
  final List<Delivery> _deliveries = List.generate(18, (index) => Delivery(
    orderId: '#123${index + 45}',
    customer: 'Customer ${index + 1}',
    address: '${index + 1} Main St, City',
    deliveryPerson: 'Driver ${index % 3 + 1}',
    status: ['Pending', 'Out for Delivery', 'Delivered', 'Failed'][index % 4],
  ));

  // Get all deliveries
  Future<List<Delivery>> getDeliveries() async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay
    return _deliveries;
  }

  // Update a delivery's status
  Future<void> updateDeliveryStatus(String orderId, String newStatus) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _deliveries.indexWhere((d) => d.orderId == orderId);
    if (index != -1) {
      final delivery = _deliveries[index];
      final updatedDelivery = Delivery(
        orderId: delivery.orderId,
        customer: delivery.customer,
        address: delivery.address,
        deliveryPerson: delivery.deliveryPerson,
        status: newStatus,
      );
      _deliveries[index] = updatedDelivery;
    }
  }
}

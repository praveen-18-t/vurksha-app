import '../models/customer_model.dart';

class CustomerRepository {
  // Mock database
  final List<Customer> _customers = List.generate(25, (index) => Customer(
    id: 'CUST${200 + index}',
    name: 'Customer Name ${index + 1}',
    email: 'customer${index + 1}@example.com',
    totalOrders: 5 + index,
    totalSpent: 2500.0 + (index * 150),
    isActive: (index % 5) != 0,
  ));

  // Get all customers
  Future<List<Customer>> getCustomers() async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay
    return _customers;
  }

  // Toggle customer status
  Future<void> toggleCustomerStatus(String customerId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _customers.indexWhere((c) => c.id == customerId);
    if (index != -1) {
      final customer = _customers[index];
      final updatedCustomer = Customer(
        id: customer.id,
        name: customer.name,
        email: customer.email,
        totalOrders: customer.totalOrders,
        totalSpent: customer.totalSpent,
        isActive: !customer.isActive,
      );
      _customers[index] = updatedCustomer;
    }
  }
}

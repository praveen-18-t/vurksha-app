class Customer {
  final String id;
  final String name;
  final String email;
  final int totalOrders;
  final double totalSpent;
  final bool isActive;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.totalOrders,
    required this.totalSpent,
    required this.isActive,
  });
}

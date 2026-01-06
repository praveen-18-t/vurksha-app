import 'package:csv/csv.dart';
import 'order_repository.dart';
import 'product_repository.dart';

class ReportRepository {
  final OrderRepository _orderRepository = OrderRepository();
  final ProductRepository _productRepository = ProductRepository();

  Future<String> generateSalesReport() async {
    final orders = await _orderRepository.getOrders();
    List<List<dynamic>> rows = [];
    rows.add(['Order ID', 'Date', 'Status', 'Total']);
    for (var order in orders) {
      rows.add([order.id, order.date.toIso8601String(), order.status, order.total]);
    }
    return const ListToCsvConverter().convert(rows);
  }

  Future<String> generateInventoryReport() async {
    final products = await _productRepository.getProducts();
    List<List<dynamic>> rows = [];
    rows.add(['Product ID', 'Name', 'Category', 'Price', 'Stock', 'Is Active']);
    for (var product in products) {
      rows.add([product.id, product.name, product.category, product.price, product.stock, product.isActive]);
    }
    return const ListToCsvConverter().convert(rows);
  }
}

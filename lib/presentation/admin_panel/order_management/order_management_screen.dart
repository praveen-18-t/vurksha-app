import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/repositories/order_repository.dart';

class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  State<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  final OrderRepository _orderRepository = OrderRepository();
  late Future<List<Order>> _ordersFuture;
  List<Order> _allOrders = [];
  List<Order> _filteredOrders = [];
  String _selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  void _fetchOrders() {
    setState(() {
      _ordersFuture = _orderRepository.getOrders();
    });
  }

  void _filterOrders(String status) {
    setState(() {
      _selectedStatus = status;
      if (status == 'All') {
        _filteredOrders = _allOrders;
      } else {
        _filteredOrders = _allOrders.where((order) => order.status == status).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order Management', style: theme.textTheme.headlineMedium),
            SizedBox(height: 2.h),
            _buildFilterChips(context),
            SizedBox(height: 2.h),
            FutureBuilder<List<Order>>(
              future: _ordersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No orders found.'));
                }
                _allOrders = snapshot.data!;
                _filterOrders(_selectedStatus); // Apply initial filter
                return _buildOrdersTable(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ['All', 'Pending', 'Processing', 'Shipped', 'Delivered'].map((status) {
          return Padding(
            padding: EdgeInsets.only(right: 2.w),
            child: FilterChip(
              label: Text(status),
              selected: _selectedStatus == status,
              onSelected: (selected) => _filterOrders(status),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOrdersTable(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 3.w,
        columns: const [
          DataColumn(label: Text('Order ID')),
          DataColumn(label: Text('Customer')),
          DataColumn(label: Text('Total')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Actions')),
        ],
        rows: _filteredOrders.map((order) {
          return DataRow(
            cells: [
              DataCell(Text(order.id)),
              DataCell(Text('Rahul Sharma')), // Real customer name
              DataCell(Text('₹${order.total.toStringAsFixed(2)}')),
              DataCell(_buildStatusChip(context, order.status)),
              DataCell(Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: Icon(Icons.edit, size: 4.w), onPressed: () => _showUpdateStatusDialog(context, order)),
                  IconButton(icon: Icon(Icons.visibility, size: 4.w), onPressed: () => _showOrderDetailsDialog(context, order)),
                ],
              )),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showUpdateStatusDialog(BuildContext context, Order order) {
    String newStatus = order.status;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Status for ${order.id}'),
          content: DropdownButton<String>(
            value: newStatus,
            items: ['Pending', 'Processing', 'Shipped', 'Delivered'].map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            onChanged: (String? value) {
              if (value != null) {
                setState(() => newStatus = value);
              }
            },
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                await _orderRepository.updateOrderStatus(order.id, newStatus);
                if (!mounted) return;
                _fetchOrders();
                Navigator.pop(context);
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showOrderDetailsDialog(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Details for ${order.id}'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Customer: Rahul Sharma'), // Real customer name
              Text('Address: ${order.deliveryAddress}'),
              Text('Total: ₹${order.total.toStringAsFixed(2)}'),
              const Divider(),
              Text('Items:', style: Theme.of(context).textTheme.titleMedium),
              ...order.items.map((item) => ListTile(title: Text('${item.name} (x${item.quantity})'))),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    Color color;
    switch (status) {
      case 'Pending': color = Colors.orange; break;
      case 'Processing': color = Colors.blue; break;
      case 'Shipped': color = Colors.purple; break;
      case 'Delivered': color = Colors.green; break;
      default: color = Colors.grey; break;
    }
    return Chip(
      label: Text(status, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.w),
    );
  }
}

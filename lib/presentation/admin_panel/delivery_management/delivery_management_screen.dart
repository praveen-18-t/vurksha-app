import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../../data/models/delivery_model.dart';
import '../../../../data/repositories/delivery_repository.dart';

class DeliveryManagementScreen extends StatefulWidget {
  const DeliveryManagementScreen({super.key});

  @override
  State<DeliveryManagementScreen> createState() => _DeliveryManagementScreenState();
}

class _DeliveryManagementScreenState extends State<DeliveryManagementScreen> {
  final DeliveryRepository _deliveryRepository = DeliveryRepository();
  late Future<List<Delivery>> _deliveriesFuture;
  List<Delivery> _allDeliveries = [];
  List<Delivery> _filteredDeliveries = [];
  String _selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    _fetchDeliveries();
  }

  void _fetchDeliveries() {
    setState(() {
      _deliveriesFuture = _deliveryRepository.getDeliveries();
    });
  }

  void _filterDeliveries(String status) {
    setState(() {
      _selectedStatus = status;
      if (status == 'All') {
        _filteredDeliveries = _allDeliveries;
      } else {
        _filteredDeliveries = _allDeliveries.where((delivery) => delivery.status == status).toList();
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
            Text('Delivery Management', style: theme.textTheme.headlineMedium),
            SizedBox(height: 2.h),
            _buildFilterChips(context),
            SizedBox(height: 2.h),
            FutureBuilder<List<Delivery>>(
              future: _deliveriesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No deliveries found.'));
                }
                _allDeliveries = snapshot.data!;
                _filterDeliveries(_selectedStatus);
                return _buildDeliveriesTable(context);
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
        children: ['All', 'Pending', 'Out for Delivery', 'Delivered', 'Failed'].map((status) {
          return Padding(
            padding: EdgeInsets.only(right: 2.w),
            child: FilterChip(
              label: Text(status),
              selected: _selectedStatus == status,
              onSelected: (selected) => _filterDeliveries(status),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDeliveriesTable(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 2.w,
        columns: const [
          DataColumn(label: Text('Order ID')),
          DataColumn(label: Text('Customer')),
          DataColumn(label: Text('Driver')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Actions')),
        ],
        rows: _filteredDeliveries.map((delivery) {
          return DataRow(
            cells: [
              DataCell(Text(delivery.orderId)),
              DataCell(Text(delivery.customer)),
              DataCell(Text(delivery.deliveryPerson)),
              DataCell(_buildStatusChip(context, delivery.status)),
              DataCell(IconButton(icon: Icon(Icons.edit, size: 4.w), onPressed: () => _showUpdateStatusDialog(context, delivery))),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showUpdateStatusDialog(BuildContext context, Delivery delivery) {
    String newStatus = delivery.status;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Status for ${delivery.orderId}'),
          content: DropdownButton<String>(
            value: newStatus,
            items: ['Pending', 'Out for Delivery', 'Delivered', 'Failed'].map((String value) {
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
                await _deliveryRepository.updateDeliveryStatus(delivery.orderId, newStatus);
                if (!mounted) return;
                _fetchDeliveries();
                Navigator.pop(context);
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    Color color;
    switch (status) {
      case 'Pending': color = Colors.orange; break;
      case 'Out for Delivery': color = Colors.blue; break;
      case 'Delivered': color = Colors.green; break;
      case 'Failed': color = Colors.red; break;
      default: color = Colors.grey; break;
    }
    return Chip(
      label: Text(status, style: const TextStyle(color: Colors.white, fontSize: 10)),
      backgroundColor: color,
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.w),
    );
  }
}

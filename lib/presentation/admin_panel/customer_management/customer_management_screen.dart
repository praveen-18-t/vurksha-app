import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../../data/models/customer_model.dart';
import '../../../../data/repositories/customer_repository.dart';

class CustomerManagementScreen extends StatefulWidget {
  const CustomerManagementScreen({super.key});

  @override
  State<CustomerManagementScreen> createState() => _CustomerManagementScreenState();
}

class _CustomerManagementScreenState extends State<CustomerManagementScreen> {
  final CustomerRepository _customerRepository = CustomerRepository();
  late Future<List<Customer>> _customersFuture;
  List<Customer> _allCustomers = [];
  List<Customer> _filteredCustomers = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _fetchCustomers() {
    setState(() {
      _customersFuture = _customerRepository.getCustomers();
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCustomers = _allCustomers.where((customer) {
        final name = customer.name.toLowerCase();
        final email = customer.email.toLowerCase();
        return name.contains(query) || email.contains(query);
      }).toList();
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
            Text('Customer Management', style: theme.textTheme.headlineMedium),
            SizedBox(height: 2.h),
            _buildSearchBar(context),
            SizedBox(height: 2.h),
            FutureBuilder<List<Customer>>(
              future: _customersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No customers found.'));
                }
                _allCustomers = snapshot.data!;
                _onSearchChanged(); // Apply initial search/filter
                return _buildCustomersTable(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return TextField(
      controller: _searchController,
      decoration: const InputDecoration(
        labelText: 'Search Customers',
        hintText: 'Search by name or email',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildCustomersTable(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 2.w,
        columns: const [
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('Orders')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Actions')),
        ],
        rows: _filteredCustomers.map((customer) {
          return DataRow(
            cells: [
              DataCell(Text(customer.name)),
              DataCell(Text(customer.email)),
              DataCell(Text('${customer.totalOrders}')),
              DataCell(_buildStatusBadge(context, customer.isActive)),
              DataCell(Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: Icon(Icons.visibility, size: 4.w), onPressed: () => _showCustomerDetailsDialog(context, customer)),
                  IconButton(
                    icon: Icon(customer.isActive ? Icons.toggle_off : Icons.toggle_on, size: 5.w, color: customer.isActive ? Colors.red : Colors.green),
                    onPressed: () => _toggleCustomerStatus(customer.id),
                  ),
                ],
              )),
            ],
          );
        }).toList(),
      ),
    );
  }

  Future<void> _toggleCustomerStatus(String customerId) async {
    await _customerRepository.toggleCustomerStatus(customerId);
    _fetchCustomers();
  }

  void _showCustomerDetailsDialog(BuildContext context, Customer customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(customer.name),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Email: ${customer.email}'),
              Text('Total Orders: ${customer.totalOrders}'),
              Text('Total Spent: ₹${customer.totalSpent.toStringAsFixed(2)}'),
              Text('Status: ${customer.isActive ? 'Active' : 'Inactive'}'),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, bool isActive) {
    return Icon(
      isActive ? Icons.check_circle : Icons.cancel,
      color: isActive ? Colors.green : Colors.red,
      size: 5.w,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/repositories/product_repository.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  final ProductRepository _productRepository = ProductRepository();
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  void _fetchProducts() {
    setState(() {
      _productsFuture = _productRepository.getProducts();
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
            Text('Product Management', style: theme.textTheme.headlineMedium),
            SizedBox(height: 2.h),
            FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No products found.'));
                }
                return _buildProductsTable(context, snapshot.data!);
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditProductDialog(context),
        tooltip: 'Add Product',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProductsTable(BuildContext context, List<Product> products) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 3.w,
        columns: const [
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Category')),
          DataColumn(label: Text('Price')),
          DataColumn(label: Text('Stock')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Actions')),
        ],
        rows: products.map((product) {
          return DataRow(
            cells: [
              DataCell(Text(product.name)),
              DataCell(Text(product.category)),
              DataCell(Text('₹${product.price}')),
              DataCell(Text('${product.stock}')),
              DataCell(_buildStatusBadge(context, product.isActive)),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, size: 4.w),
                      onPressed: () =>
                          _showAddEditProductDialog(context, product: product),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete,
                        size: 4.w,
                        color: theme.colorScheme.error,
                      ),
                      onPressed: () => _deleteProduct(product.id),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
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

  Future<void> _deleteProduct(String productId) async {
    await _productRepository.deleteProduct(productId);
    _fetchProducts();
  }

  void _showAddEditProductDialog(BuildContext context, {Product? product}) {
    final isEditing = product != null;
    final formKey = GlobalKey<FormState>();
    String name = isEditing ? product.name : '';
    String category = isEditing ? product.category : '';
    double price = isEditing ? product.price : 0.0;
    int stock = isEditing ? product.stock : 0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Product' : 'Add Product'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: name,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter a name' : null,
                    onSaved: (value) => name = value!,
                  ),
                  TextFormField(
                    initialValue: category,
                    decoration: const InputDecoration(labelText: 'Category'),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter a category' : null,
                    onSaved: (value) => category = value!,
                  ),
                  TextFormField(
                    initialValue: price.toString(),
                    decoration: const InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value!.isEmpty || double.tryParse(value) == null
                        ? 'Please enter a valid price'
                        : null,
                    onSaved: (value) => price = double.parse(value!),
                  ),
                  TextFormField(
                    initialValue: stock.toString(),
                    decoration: const InputDecoration(labelText: 'Stock'),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value!.isEmpty || int.tryParse(value) == null
                        ? 'Please enter a valid stock quantity'
                        : null,
                    onSaved: (value) => stock = int.parse(value!),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  final newProduct = Product(
                    id: isEditing
                        ? product.id
                        : 'PROD${DateTime.now().millisecondsSinceEpoch}',
                    name: name,
                    category: category,
                    price: price,
                    stock: stock,
                    isActive: isEditing ? product.isActive : true,
                  );
                  if (isEditing) {
                    await _productRepository.updateProduct(newProduct);
                  } else {
                    await _productRepository.addProduct(newProduct);
                  }
                  if (!mounted) return;
                  _fetchProducts();
                  Navigator.pop(context);
                }
              },
              child: Text(isEditing ? 'Save' : 'Add'),
            ),
          ],
        );
      },
    );
  }
}

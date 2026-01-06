import 'package:flutter/material.dart';

/// Similar Products Widget
class SimilarProductsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems;
  final List<Map<String, dynamic>> similarProducts;
  final Function(String)? onProductTap;

  const SimilarProductsWidget({
    super.key,
    required this.cartItems,
    this.similarProducts = const [],
    this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Similar Products',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text('Customers also bought'),
          const Text('Based on your cart items'),
          // Show similar products based on cart items
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (context, index) {
                return Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text('Product $index'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

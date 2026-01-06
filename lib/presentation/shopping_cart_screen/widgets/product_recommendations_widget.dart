import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../data/providers/cart_provider.dart';
import '../../../data/models/cart_model.dart';

/// Product recommendations widget for cross-selling
class ProductRecommendationsWidget extends ConsumerWidget {
  const ProductRecommendationsWidget({super.key});

  // Realistic recommended products data
  final List<Map<String, dynamic>> _recommendedProducts = const [
    {
      "id": "rec1",
      "name": "Organic Red Capsicum",
      "price": 45.0,
      "unit": "kg",
      "image": "https://images.unsplash.com/photo-1581375321224-79da6fd32f5e",
      "rating": 4.7,
      "discount": 15,
    },
    {
      "id": "rec2", 
      "name": "Fresh Broccoli",
      "price": 60.0,
      "unit": "kg",
      "image": "https://images.unsplash.com/photo-1459411621453-7b03977f4bfc",
      "rating": 4.6,
      "discount": 10,
    },
    {
      "id": "rec3",
      "name": "Baby Spinach",
      "price": 40.0,
      "unit": "kg", 
      "image": "https://images.unsplash.com/photo-1576091160550-2173dba999ef",
      "rating": 4.8,
      "discount": 5,
    },
    {
      "id": "rec4",
      "name": "Sweet Corn",
      "price": 35.0,
      "unit": "kg",
      "image": "https://images.unsplash.com/photo-1593720219276-0b1eac5ba9ba",
      "rating": 4.5,
      "discount": 0,
    },
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cartNotifier = ref.read(cartProvider.notifier);

    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'You might also like',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('View all products coming soon!')),
                  );
                },
                child: Text(
                  'View All',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Recommendations list
          SizedBox(
            height: 28.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _recommendedProducts.length,
              itemBuilder: (context, index) {
                final product = _recommendedProducts[index];
                return Container(
                  width: 40.w,
                  margin: EdgeInsets.only(right: 3.w),
                  child: Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${product['name']} details coming soon!')),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.all(2.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product image with discount badge
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CustomImageWidget(
                                    imageUrl: product['image'],
                                    height: 15.h,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    semanticLabel: product['name'],
                                  ),
                                ),
                                if (product['discount'] > 0)
                                  Positioned(
                                    top: 1.h,
                                    right: 1.w,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 1.5.w,
                                        vertical: 0.3.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.error,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${product['discount']}% OFF',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onError,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 1.h),

                            // Product name
                            Text(
                              product['name'],
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 0.5.h),

                            // Rating
                            Row(
                              children: [
                                ...List.generate(5, (starIndex) {
                                  return CustomIconWidget(
                                    iconName: starIndex < (product['rating'] as double).floor()
                                        ? 'star'
                                        : 'star_border',
                                    size: 12,
                                    color: theme.colorScheme.primary,
                                  );
                                }),
                                SizedBox(width: 1.w),
                                Text(
                                  product['rating'].toString(),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),

                            // Price and add button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (product['discount'] > 0) ...[
                                      Text(
                                        '₹${product['price'].toStringAsFixed(2)}/${product['unit']}',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
                                          decoration: TextDecoration.lineThrough,
                                        ),
                                      ),
                                      Text(
                                        '₹${(product['price'] * (1 - product['discount'] / 100)).toStringAsFixed(2)}/${product['unit']}',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ] else ...[
                                      Text(
                                        '₹${product['price'].toStringAsFixed(2)}/${product['unit']}',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                // Add button
                                InkWell(
                                  onTap: () {
                                    final cartItem = CartItem(
                                      id: product['id'],
                                      name: product['name'],
                                      description: "Recommended product",
                                      pricePerUnit: product['price'] * (1 - product['discount'] / 100),
                                      quantity: 1,
                                      unit: product['unit'],
                                      imageUrl: product['image'],
                                      stockAvailable: 999,
                                      tags: [],
                                      addedAt: DateTime.now(),
                                    );
                                    cartNotifier.addItem(cartItem);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${product['name']} added to cart'),
                                        backgroundColor: theme.colorScheme.primary,
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: EdgeInsets.all(1.5.w),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: CustomIconWidget(
                                      iconName: 'add',
                                      size: 16,
                                      color: theme.colorScheme.onPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
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

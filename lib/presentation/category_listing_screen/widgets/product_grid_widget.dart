import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Vertical grid of product cards with 2 columns
class ProductGridWidget extends StatelessWidget {
  const ProductGridWidget({
    super.key,
    required this.products,
    required this.onProductTap,
    required this.onAddToWishlist,
    required this.onShareProduct,
    required this.onViewSimilar,
    this.isLoading = false,
  });

  final List<Map<String, dynamic>> products;
  final ValueChanged<Map<String, dynamic>> onProductTap;
  final ValueChanged<Map<String, dynamic>> onAddToWishlist;
  final ValueChanged<Map<String, dynamic>> onShareProduct;
  final ValueChanged<Map<String, dynamic>> onViewSimilar;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildSkeletonGrid(context);
    }

    if (products.isEmpty) {
      return _buildEmptyState(context);
    }

    return GridView.builder(
      padding: EdgeInsets.all(4.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 4.w,
        mainAxisSpacing: 2.h,
        childAspectRatio: 0.75,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return _buildProductCard(context, products[index]);
      },
    );
  }

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> product) {
    final theme = Theme.of(context);
    final isOutOfStock = product['stock'] == 0;

    return GestureDetector(
      onTap: () => onProductTap(product),
      onLongPress: () => _showQuickActions(context, product),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: CustomImageWidget(
                      imageUrl: product['image'] as String,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      semanticLabel: product['semanticLabel'] as String,
                    ),
                  ),
                ),
                // Product Details
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(2.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product['name'] as String,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          product['weight'] as String,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              product['price'] as String,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (!isOutOfStock)
                              Container(
                                padding: EdgeInsets.all(1.5.w),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: CustomIconWidget(
                                  iconName: 'add',
                                  color: theme.colorScheme.onPrimary,
                                  size: 4.w,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Out of Stock Overlay
            if (isOutOfStock)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Out of Stock',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Product details coming soon!')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            padding: EdgeInsets.symmetric(
                              horizontal: 4.w,
                              vertical: 1.h,
                            ),
                          ),
                          child: Text(
                            'Notify Me',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            // Organic Badge
            if (product['isOrganic'] == true)
              Positioned(
                top: 2.w,
                right: 2.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 0.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Organic',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showQuickActions(BuildContext context, Map<String, dynamic> product) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10.w,
                height: 0.5.h,
                margin: EdgeInsets.symmetric(vertical: 1.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'favorite_border',
                  color: theme.colorScheme.primary,
                  size: 6.w,
                ),
                title: Text(
                  'Add to Wishlist',
                  style: theme.textTheme.bodyLarge,
                ),
                onTap: () {
                  Navigator.pop(context);
                  onAddToWishlist(product);
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'share',
                  color: theme.colorScheme.primary,
                  size: 6.w,
                ),
                title: Text('Share Product', style: theme.textTheme.bodyLarge),
                onTap: () {
                  Navigator.pop(context);
                  onShareProduct(product);
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'grid_view',
                  color: theme.colorScheme.primary,
                  size: 6.w,
                ),
                title: Text('View Similar', style: theme.textTheme.bodyLarge),
                onTap: () {
                  Navigator.pop(context);
                  onViewSimilar(product);
                },
              ),
              SizedBox(height: 2.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSkeletonGrid(BuildContext context) {
    final theme = Theme.of(context);

    return GridView.builder(
      padding: EdgeInsets.all(4.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 4.w,
        mainAxisSpacing: 2.h,
        childAspectRatio: 0.75,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 20.h,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(2.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 30.w,
                      height: 1.5.h,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Container(
                      width: 20.w,
                      height: 1.h,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'search_off',
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            size: 20.w,
          ),
          SizedBox(height: 2.h),
          Text(
            'No products found',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Try different filters or search terms',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Clear filters feature coming soon!')),
              );
            },
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }
}

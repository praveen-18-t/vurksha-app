import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../data/models/product_model.dart';

/// Featured products widget displaying grid of products
/// Shows product images, names, prices, and quick add to cart
class FeaturedProductsWidget extends StatelessWidget {
  const FeaturedProductsWidget({
    super.key,
    required this.products,
    required this.onProductTap,
    required this.onAddToCart,
  });

  final List<Product> products;
  final Function(String productId) onProductTap;
  final Function(String productId) onAddToCart;

  @override
  Widget build(BuildContext context) {
    return ProductGrid(
      products: products.map((product) => product.toMap()).toList(),
      onProductTap: (productId) => onProductTap(productId.toString()),
      onAddToCart: (productId) => onAddToCart(productId.toString()),
    );
  }
}

class ProductGrid extends StatelessWidget {
  const ProductGrid({
    super.key,
    required this.products,
    required this.onProductTap,
    required this.onAddToCart,
  });

  final List<Map<String, dynamic>> products;
  final Function(String productId) onProductTap;
  final Function(String productId) onAddToCart;

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);
    final scale = textScaler.scale(1.0);
    final tileExtent = (300.0 * scale).clamp(280.0, 360.0);

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: tileExtent,
        crossAxisSpacing: 3.w,
        mainAxisSpacing: 2.h,
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        final product = Product.fromMap(products[index]);
        return ProductCard(
          key: ValueKey(product.id),
          product: product,
          onTap: () => onProductTap(product.id),
          onAddToCart: () => onAddToCart(product.id),
        );
      }, childCount: products.length),
    );
  }
}

/// Individual product card widget
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onAddToCart,
  });

  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inStock = product.isInStock;
    final certified = product.isOrganic;
    final discount = product.discountPercentage?.toInt() ?? 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image with badges
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: CustomImageWidget(
                      imageUrl: product.image,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      semanticLabel: product.name,
                    ),
                  ),
                ),

                // Certified badge
                if (certified)
                  Positioned(
                    top: 2.w,
                    left: 2.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 0.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomIconWidget(
                            iconName: 'verified',
                            color: Colors.white,
                            size: 12,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            'Organic',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Discount badge
                if (discount > 0)
                  Positioned(
                    top: 2.w,
                    right: 2.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 0.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$discount% OFF',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                // Out of stock overlay
                if (!inStock)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 3.w,
                            vertical: 1.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Out of Stock',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Product details
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(3.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      product.unit,
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
                          '₹${product.effectivePrice.toStringAsFixed(0)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        if (inStock)
                          InkWell(
                            onTap: onAddToCart,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: EdgeInsets.all(1.5.w),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: CustomIconWidget(
                                iconName: 'add',
                                color: Colors.white,
                                size: 20,
                              ),
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
      ),
    );
  }
}

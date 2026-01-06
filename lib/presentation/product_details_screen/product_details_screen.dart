import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../data/models/cart_model.dart' as cart_model;
import '../../data/providers/cart_provider.dart' as cart_provider;
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/customer_reviews_widget.dart';
import './widgets/price_quantity_widget.dart';
import './widgets/product_description_widget.dart';
import './widgets/product_image_gallery_widget.dart';
import './widgets/product_image_gallery_widget.dart';
import './widgets/product_info_widget.dart';
import './widgets/stock_availability_widget.dart';
import './widgets/weight_options_widget.dart';

/// Product Details Screen - Comprehensive organic product information with purchase options
class ProductDetailsScreen extends ConsumerStatefulWidget {
  const ProductDetailsScreen({super.key});

  @override
  ConsumerState<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> {
  bool _isWishlisted = false;
  int _quantity = 1;
  int _cartQuantity = 0;
  Map<String, dynamic>? _selectedWeight;
  bool _isLoading = false;

  // Realistic product data
  final Map<String, dynamic> _productData = {
    'id': 'prod_001',
    'name': 'Premium Organic Tomatoes',
    'farmSource': 'Sunshine Organic Farms, Nashik',
    'isOrganic': true,
    'pricePerKg': 85.0,
    'unit': 'kg',
    'stockCount': 8,
    'inStock': true,
    'description':
        'Hand-picked premium organic tomatoes grown in controlled greenhouse conditions. These vine-ripened tomatoes are rich in flavor and perfect for salads, cooking, and making sauces. Pesticide-free and naturally ripened for maximum taste and nutrition.',
    'nutritionalBenefits':
        'Excellent source of Vitamin C, potassium, folate, and Vitamin K. Contains powerful antioxidants like lycopene which supports heart health and may reduce cancer risk. Low in calories and high in fiber, making them ideal for weight management and digestive health.',
    'farmingPractices':
        'Grown using advanced organic farming methods with natural compost and beneficial insects. Our farmers practice companion planting and crop rotation to maintain soil health. No synthetic pesticides, herbicides, or GMO seeds are used. Each tomato is carefully hand-harvested at peak ripeness.',
    'images': [
      {
        'url': 'https://images.unsplash.com/photo-1569209548020-2fb7c81253a8',
        'semanticLabel':
            'Fresh red organic tomatoes arranged on wooden surface with green leaves',
      },
      {
        'url': 'https://images.unsplash.com/photo-1615408957144-6d0cd7d3c38e',
        'semanticLabel':
            'Close-up of ripe red tomatoes on vine in organic farm',
      },
      {
        'url': 'https://images.unsplash.com/photo-1461869762023-caaba96eb45f',
        'semanticLabel':
            'Basket of freshly harvested organic tomatoes in sunlight',
      },
    ],
    'weightOptions': [
      {'weight': '500g', 'price': 40.0},
      {'weight': '1kg', 'price': 80.0},
      {'weight': '2kg', 'price': 150.0},
    ],
    'reviews': [],
    'averageRating': 0.0,
    'totalReviews': 0,
  };

  @override
  void initState() {
    super.initState();
    _selectedWeight = _productData['weightOptions'][1] as Map<String, dynamic>;
  }

  void _handleQuantityChange(int quantity) {
    setState(() {
      _quantity = quantity;
    });
  }

  void _handleWeightChange(Map<String, dynamic> weight) {
    setState(() {
      _selectedWeight = weight;
    });
  }

  void _toggleWishlist() {
    setState(() {
      _isWishlisted = !_isWishlisted;
    });
    HapticFeedback.mediumImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isWishlisted ? 'Added to wishlist' : 'Removed from wishlist',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareProduct() {
    final productUrl = 'https://vurkshafarm.com/product/${_productData['id']}';
    SharePlus.instance.share(
      ShareParams(
        subject: 'Fresh Organic Produce',
        text:
            'Check out ${_productData['name']} on Vurksha Farm Delivery!\n\n$productUrl',
      ),
    );
  }

  Future<void> _addToCart() async {
    if (_selectedWeight == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Create cart item
      final cartItem = cart_model.CartItem(
        id: '${_productData['id']}_${_selectedWeight!['id']}',
        name: '${_productData['name']} (${_selectedWeight!['weight']})',
        description: _productData['description'] as String,
        pricePerUnit: (_selectedWeight!['price'] as num).toDouble(),
        quantity: _quantity,
        unit: _selectedWeight!['unit'] as String,
        imageUrl: _productData['image'] as String,
        stockAvailable: _selectedWeight!['stock'] as int,
        addedAt: DateTime.now(),
      );

      // Add to cart
      ref.read(cart_provider.cartProvider.notifier).addItem(cartItem);

      // Update local UI state
      setState(() {
        _cartQuantity += _quantity;
      });

      HapticFeedback.mediumImpact();

      if (!mounted) return;

      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Added $_quantity ${_selectedWeight!['weight']} to cart',
          ),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'View Cart',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.shoppingCart);
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      // Show error feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add item to cart'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        variant: AppBarVariant.detail,
        showBackButton: true,
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: _isWishlisted ? 'favorite' : 'favorite_border',
              color: _isWishlisted ? Colors.red : theme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: _toggleWishlist,
            tooltip: 'Add to wishlist',
          ),
          IconButton(
            icon: CustomIconWidget(
              iconName: 'share',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: _shareProduct,
            tooltip: 'Share',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product image gallery
                  ProductImageGalleryWidget(
                    images: (_productData['images'] as List)
                        .cast<Map<String, dynamic>>(),
                  ),

                  // Product info
                  ProductInfoWidget(
                    productName: _productData['name'] as String,
                    farmSource: _productData['farmSource'] as String,
                    isOrganic: _productData['isOrganic'] as bool,
                  ),

                  // Price and quantity
                  PriceQuantityWidget(
                    pricePerUnit: _selectedWeight!['price'] as double,
                    unit: _selectedWeight!['weight'] as String,
                    onQuantityChanged: _handleQuantityChange,
                    initialQuantity: _quantity,
                  ),

                  // Weight options
                  WeightOptionsWidget(
                    weightOptions: (_productData['weightOptions'] as List)
                        .cast<Map<String, dynamic>>(),
                    onWeightSelected: _handleWeightChange,
                  ),

                  // Stock availability
                  StockAvailabilityWidget(
                    stockCount: _productData['stockCount'] as int,
                    inStock: _productData['inStock'] as bool,
                  ),

                  // Product description
                  ProductDescriptionWidget(
                    description: _productData['description'] as String,
                    nutritionalBenefits:
                        _productData['nutritionalBenefits'] as String,
                    farmingPractices:
                        _productData['farmingPractices'] as String,
                  ),

                  // Customer reviews
                  CustomerReviewsWidget(
                    reviews: (_productData['reviews'] as List)
                        .cast<Map<String, dynamic>>(),
                    averageRating: _productData['averageRating'] as double,
                    totalReviews: _productData['totalReviews'] as int,
                  ),

                  SizedBox(height: 10.h),
                ],
              ),
            ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow,
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              if (_cartQuantity > 0) ...[
                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                      vertical: 1.h,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(2.h),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: 'shopping_cart',
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        SizedBox(width: 1.w),
                        Flexible(
                          child: Text(
                            '$_cartQuantity in cart',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
              ],
              Flexible(
                flex: 2, // Give more space to the button
                child: ElevatedButton(
                  onPressed: (_productData['inStock'] as bool)
                      ? _addToCart
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2.h),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'add_shopping_cart',
                        color: theme.colorScheme.onPrimary,
                        size: 20,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        (_productData['inStock'] as bool)
                            ? 'Add to Cart'
                            : 'Out of Stock',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

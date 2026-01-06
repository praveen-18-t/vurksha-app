import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../data/models/product_model.dart';
import '../../data/providers/cart_provider.dart';
import '../../data/models/cart_model.dart';
import '../../data/repositories/product_repository.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/featured_products_widget.dart';
import './widgets/hero_carousel_widget.dart';
import './widgets/home_app_bar.dart';
import './widgets/category_carousel_widget.dart';

/// Home Screen - Primary discovery hub for organic produce
/// Implements bottom tab navigation with Home tab active
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentBottomNavIndex = 0;
  final ScrollController _scrollController = ScrollController();
  List<Product> _products = [];

  // Hero carousel banners
  final List<HeroCarouselBanner> _heroBanners = [
    HeroCarouselBanner(
      id: 'banner1',
      title: 'Fresh Organic Vegetables',
      subtitle: 'Farm-to-table delivery in 24 hours',
      imageUrl: 'https://images.unsplash.com/photo-1590779073100-3f0a4db5b3f6',
      tag: 'NEW',
    ),
    HeroCarouselBanner(
      id: 'banner2',
      title: 'Seasonal Fruits Collection',
      subtitle: 'Get 20% off on all seasonal fruits',
      imageUrl: 'https://images.unsplash.com/photo-1519996529931-28324d5a630e',
      tag: 'OFFER',
    ),
    HeroCarouselBanner(
      id: 'banner3',
      title: 'Organic Dairy Products',
      subtitle: 'Fresh from local organic farms',
      imageUrl: 'https://images.unsplash.com/photo-1550583724-b2692b85b150',
      tag: 'POPULAR',
    ),
    HeroCarouselBanner(
      id: 'banner4',
      title: 'Farm Fresh Eggs',
      subtitle: 'Free-range organic eggs from happy chickens',
      imageUrl: 'https://images.unsplash.com/photo-1517496388835-d4670cbf309b',
      tag: 'FRESH',
    ),
    HeroCarouselBanner(
      id: 'banner5',
      title: 'Premium Dry Fruits',
      subtitle: 'Organic nuts and dried fruits from select farms',
      imageUrl: 'https://images.unsplash.com/photo-1528722828814-77b9b83aafb2',
      tag: 'PREMIUM',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Load initial data for home screen
  Future<void> _loadInitialData() async {
    // Load products
    final products = await ProductRepository().getProducts();
    setState(() {
      _products = products;
    });
  }

  /// Handle pull-to-refresh with haptic feedback
  Future<void> _handleRefresh() async {
    // Simulate refresh with haptic feedback
    await Future.delayed(const Duration(seconds: 1));
  }

  /// Handle bottom navigation tap
  void _onBottomNavTap(int index) {
    setState(() => _currentBottomNavIndex = index);
  }

  /// Handle add to cart action
  void _handleAddToCart(String productId) {
    final theme = Theme.of(context);
    final product = _products.firstWhere((p) => p.id == productId);
    
    // Create cart item
    final cartItem = CartItem(
      id: productId,
      name: product.name,
      description: product.description,
      pricePerUnit: product.price,
      quantity: 1,
      unit: product.unit,
      imageUrl: product.image,
      stockAvailable: product.stock,
      tags: product.tags,
      addedAt: DateTime.now(),
    );
    
    // Add to cart using provider
    ref.read(cartProvider.notifier).addItem(cartItem);
    
    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${product.name} added to cart',
          style: theme.snackBarTheme.contentTextStyle,
        ),
        backgroundColor: theme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'View Cart',
          textColor: Colors.white,
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.shoppingCart);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: HomeAppBar(
        onLogoTap: () {
          if (!_scrollController.hasClients) return;
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        },
        onSearchTap: _showSearchOverlay,
        onNotificationTap: () {
          Navigator.pushNamed(context, AppRoutes.notifications);
        },
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: theme.colorScheme.primary,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Hero Carousel Section
              SliverToBoxAdapter(
                child: HeroCarouselWidget(
                  banners: _heroBanners,
                  onBannerTap: (banner) {
                    debugPrint('Banner tapped: ${banner.title}');
                  },
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              
              // Shop by Category Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  child: CategoryCarouselWidget(
                    onCategoryTap: (categoryName) {
                      Navigator.pushNamed(
                        context,
                        '/category-listing-screen',
                        arguments: {'category': categoryName},
                      );
                    },
                  ),
                ),
              ),

              // Featured Products Section Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 1.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Featured Products',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/category-listing-screen',
                          );
                        },
                        child: Text(
                          'View All',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Featured Products Grid
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                sliver: FeaturedProductsWidget(
                  products: _products,
                  onProductTap: (productId) {
                    Navigator.pushNamed(
                      context,
                      '/product-details-screen',
                      arguments: {'productId': productId},
                    );
                  },
                  onAddToCart: (productId) {
                    _handleAddToCart(productId);
                  },
                ),
              ),

              // Bottom spacing to prevent bottom nav overlap
              SliverToBoxAdapter(
                child: SizedBox(
                  height:
                      kBottomNavigationBarHeight +
                      MediaQuery.of(context).padding.bottom,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomNavIndex,
        onTap: _onBottomNavTap,
        variant: BottomBarVariant.standard,
        showLabels: true,
      ),
    );
  }

  /// Show search overlay with full-screen interface
  void _showSearchOverlay() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SearchOverlay(),
    );
  }
}

/// Search overlay widget for full-screen search interface
class _SearchOverlay extends StatefulWidget {
  @override
  State<_SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends State<_SearchOverlay> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _recentSearches = [
    'Organic Tomatoes',
    'Fresh Spinach',
    'Seasonal Fruits',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FractionallySizedBox(
      heightFactor: 0.9,
      child: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Search header
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Search fresh products...',
                        prefixIcon: CustomIconWidget(
                          iconName: 'search',
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                          size: 24,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                  ),
                ],
              ),
            ),

            // Recent searches
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(4.w),
                children: [
                  Text(
                    'Recent Searches',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  ..._recentSearches.map(
                    (search) => ListTile(
                      leading: CustomIconWidget(
                        iconName: 'history',
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                        size: 20,
                      ),
                      title: Text(search),
                      trailing: CustomIconWidget(
                        iconName: 'north_west',
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.4,
                        ),
                        size: 16,
                      ),
                      onTap: () {
                        _searchController.text = search;
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

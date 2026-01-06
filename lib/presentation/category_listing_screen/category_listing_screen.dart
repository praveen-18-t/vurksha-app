import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/filter_chips_widget.dart';
import './widgets/product_grid_widget.dart';
import './widgets/search_bar_widget.dart';
import './widgets/sort_button_widget.dart';

class CategoryListingScreen extends StatefulWidget {
  const CategoryListingScreen({super.key});

  @override
  State<CategoryListingScreen> createState() => _CategoryListingScreenState();
}

class _CategoryListingScreenState extends State<CategoryListingScreen> {
  final ScrollController _scrollController = ScrollController();

  // State variables
  String _searchQuery = '';
  String _currentSort = 'popularity';
  final Map<String, int> _activeFilters = {};
  bool _isLoading = false;
  bool _isLoadingMore = false;
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _filteredProducts = [];

  // Mock data
  final List<Map<String, dynamic>> _mockProducts = [
    {
      "id": 1,
      "name": "Fresh Organic Tomatoes",
      "category": "Vegetables",
      "price": "₹80",
      "weight": "500g",
      "stock": 25,
      "isOrganic": true,
      "image": "https://images.unsplash.com/photo-1662461484090-418a560ac78b",
      "semanticLabel":
          "Bright red organic tomatoes on wooden surface with green stems visible",
    },
    {
      "id": 2,
      "name": "Green Capsicum",
      "category": "Vegetables",
      "price": "₹60",
      "weight": "250g",
      "stock": 15,
      "isOrganic": true,
      "image": "https://images.unsplash.com/photo-1723110569384-800b1641c8a3",
      "semanticLabel":
          "Fresh green bell peppers with glossy skin on white background",
    },
    {
      "id": 3,
      "name": "Fresh Spinach Leaves",
      "category": "Leafy Greens",
      "price": "₹40",
      "weight": "200g",
      "stock": 0,
      "isOrganic": true,
      "image": "https://images.unsplash.com/photo-1695225970590-df52572fa1d5",
      "semanticLabel":
          "Bundle of fresh green spinach leaves with water droplets",
    },
    {
      "id": 4,
      "name": "Organic Carrots",
      "category": "Vegetables",
      "price": "₹50",
      "weight": "500g",
      "stock": 30,
      "isOrganic": true,
      "image": "https://images.unsplash.com/photo-1549394907-7201db0924e7",
      "semanticLabel":
          "Orange carrots with green tops arranged on rustic wooden table",
    },
    {
      "id": 5,
      "name": "Fresh Broccoli",
      "category": "Vegetables",
      "price": "₹90",
      "weight": "300g",
      "stock": 12,
      "isOrganic": true,
      "image": "https://images.unsplash.com/photo-1613572291502-73ffbf6cb1ea",
      "semanticLabel":
          "Green broccoli florets with thick stems on white surface",
    },
    {
      "id": 6,
      "name": "Red Onions",
      "category": "Vegetables",
      "price": "₹45",
      "weight": "1kg",
      "stock": 40,
      "isOrganic": false,
      "image": "https://images.unsplash.com/photo-1687628388029-67365be6b108",
      "semanticLabel": "Purple-red onions with papery skin in woven basket",
    },
    {
      "id": 7,
      "name": "Fresh Cauliflower",
      "category": "Vegetables",
      "price": "₹70",
      "weight": "1 piece",
      "stock": 18,
      "isOrganic": true,
      "image": "https://images.unsplash.com/photo-1589719305307-45bb6b537b37",
      "semanticLabel":
          "White cauliflower head with green leaves on dark background",
    },
    {
      "id": 8,
      "name": "Green Beans",
      "category": "Vegetables",
      "price": "₹55",
      "weight": "250g",
      "stock": 22,
      "isOrganic": true,
      "image": "https://images.unsplash.com/photo-1591081846032-d951a3a1cbe6",
      "semanticLabel": "Fresh green beans scattered on white marble surface",
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadProducts() {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _products = List.from(_mockProducts);
          _filteredProducts = List.from(_products);
          _isLoading = false;
        });
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _filteredProducts.length < 50) {
        _loadMoreProducts();
      }
    }
  }

  void _loadMoreProducts() {
    setState(() => _isLoadingMore = true);

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          // Simulate loading more products
          _isLoadingMore = false;
        });
      }
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void _onFilterRemoved(String filterKey) {
    setState(() {
      _activeFilters.remove(filterKey);
      _applyFilters();
    });
  }

  void _onSortSelected(String sortType) {
    setState(() {
      _currentSort = sortType;
      _applySorting();
    });
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(_products);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((product) {
        final name = (product['name'] as String).toLowerCase();
        return name.contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply active filters
    if (_activeFilters.containsKey('Organic')) {
      filtered = filtered
          .where((product) => product['isOrganic'] == true)
          .toList();
    }

    if (_activeFilters.containsKey('In Stock')) {
      filtered = filtered
          .where((product) => (product['stock'] as int) > 0)
          .toList();
    }

    setState(() {
      _filteredProducts = filtered;
      _applySorting();
    });
  }

  void _applySorting() {
    switch (_currentSort) {
      case 'price_asc':
        _filteredProducts.sort((a, b) {
          final priceA = int.parse(
            (a['price'] as String).replaceAll(RegExp(r'[^\d]'), ''),
          );
          final priceB = int.parse(
            (b['price'] as String).replaceAll(RegExp(r'[^\d]'), ''),
          );
          return priceA.compareTo(priceB);
        });
        break;
      case 'price_desc':
        _filteredProducts.sort((a, b) {
          final priceA = int.parse(
            (a['price'] as String).replaceAll(RegExp(r'[^\d]'), ''),
          );
          final priceB = int.parse(
            (b['price'] as String).replaceAll(RegExp(r'[^\d]'), ''),
          );
          return priceB.compareTo(priceA);
        });
        break;
      case 'newest':
        _filteredProducts.sort(
          (a, b) => (b['id'] as int).compareTo(a['id'] as int),
        );
        break;
      case 'popularity':
      default:
        _filteredProducts.sort(
          (a, b) => (b['stock'] as int).compareTo(a['stock'] as int),
        );
        break;
    }
  }

  void _onProductTap(Map<String, dynamic> product) {
    Navigator.pushNamed(context, '/product-details-screen', arguments: product);
  }

  void _onAddToWishlist(Map<String, dynamic> product) {
    Fluttertoast.showToast(
      msg: "${product['name']} added to wishlist",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _onShareProduct(Map<String, dynamic> product) {
    Fluttertoast.showToast(
      msg: "Sharing ${product['name']}",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _onViewSimilar(Map<String, dynamic> product) {
    Fluttertoast.showToast(
      msg: "Showing similar products",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _showFilterModal() {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Container(
                constraints: BoxConstraints(maxHeight: 70.h),
                padding: EdgeInsets.all(4.w),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Filters',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          IconButton(
                            icon: CustomIconWidget(
                              iconName: 'close',
                              color: theme.colorScheme.onSurface,
                              size: 6.w,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Expanded(
                        child: ListView(
                          children: [
                            _buildFilterSection(theme, 'Availability', [
                              {'label': 'In Stock', 'value': 'in_stock'},
                              {
                                'label': 'Out of Stock',
                                'value': 'out_of_stock',
                              },
                            ], setModalState),
                            SizedBox(height: 2.h),
                            _buildFilterSection(theme, 'Certification', [
                              {
                                'label': 'Organic Certified',
                                'value': 'organic',
                              },
                            ], setModalState),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setModalState(() => _activeFilters.clear());
                                setState(() => _applyFilters());
                              },
                              child: const Text('Clear All'),
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() => _applyFilters());
                                Navigator.pop(context);
                              },
                              child: const Text('Apply Filters'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterSection(
    ThemeData theme,
    String title,
    List<Map<String, String>> options,
    StateSetter setModalState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        ...options.map((option) {
          final isSelected = _activeFilters.containsKey(option['label']);
          return CheckboxListTile(
            title: Text(option['label'] as String),
            value: isSelected,
            onChanged: (value) {
              setModalState(() {
                if (value == true) {
                  _activeFilters[option['label'] as String] = 1;
                } else {
                  _activeFilters.remove(option['label']);
                }
              });
            },
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        variant: AppBarVariant.detail,
        title: Text('Fresh Vegetables', style: theme.textTheme.titleLarge),
        showBackButton: true,
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'filter_list',
              color: theme.colorScheme.onSurface,
              size: 6.w,
            ),
            onPressed: _showFilterModal,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadProducts();
        },
        child: Column(
          children: [
            SearchBarWidget(onSearchChanged: _onSearchChanged),
            FilterChipsWidget(
              activeFilters: _activeFilters,
              onFilterRemoved: _onFilterRemoved,
              onFilterTap: _showFilterModal,
            ),
            SizedBox(height: 1.h),
            Expanded(
              child: ProductGridWidget(
                products: _filteredProducts,
                onProductTap: _onProductTap,
                onAddToWishlist: _onAddToWishlist,
                onShareProduct: _onShareProduct,
                onViewSimilar: _onViewSimilar,
                isLoading: _isLoading,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SortButtonWidget(
        onSortSelected: _onSortSelected,
        currentSort: _currentSort,
      ),
    );
  }
}

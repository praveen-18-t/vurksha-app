import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Category carousel widget displaying horizontal scrolling categories
/// Shows Vegetables, Fruits, Leafy Greens, Combos with colorful icons
class CategorySection extends StatelessWidget {
  const CategorySection({super.key, required this.onCategoryTap});

  final Function(String categoryName) onCategoryTap;

  // Mock category data
  static final List<Map<String, dynamic>> _categories = [
    {
      'id': 1,
      'name': 'Vegetables',
      'icon': 'eco',
      'color': 0xFF4CAF50,
      'count': 45,
    },
    {
      'id': 2,
      'name': 'Fruits',
      'icon': 'apple',
      'color': 0xFFFF6F00,
      'count': 32,
    },
    {
      'id': 3,
      'name': 'Leafy Greens',
      'icon': 'grass',
      'color': 0xFF2E7D32,
      'count': 28,
    },
    {
      'id': 4,
      'name': 'Dairy',
      'icon': 'egg',
      'color': 0xFF2196F3,
      'count': 20,
    },
    {
      'id': 5,
      'name': 'Combos',
      'icon': 'shopping_basket',
      'color': 0xFF558B2F,
      'count': 15,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textScaler = MediaQuery.textScalerOf(context);
    final textScaleFactor = textScaler.scale(1.0);
    final carouselHeight = (112.0 * textScaleFactor).clamp(112.0, 160.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            'Shop by Category',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        SizedBox(height: 2.h),
        ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: carouselHeight,
            maxHeight: carouselHeight,
          ),
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (context, index) => SizedBox(width: 3.w),
            itemBuilder: (context, index) {
              final category = _categories[index];
              return CategoryItem(
                key: ValueKey(category['id']),
                category: category,
                onTap: () => onCategoryTap(category['name'] as String),
              );
            },
          ),
        ),
      ],
    );
  }
}

class CategoryCarouselWidget extends StatelessWidget {
  const CategoryCarouselWidget({super.key, required this.onCategoryTap});

  final Function(String categoryName) onCategoryTap;

  @override
  Widget build(BuildContext context) {
    return CategorySection(onCategoryTap: onCategoryTap);
  }
}

/// Individual category card widget
class CategoryItem extends StatelessWidget {
  const CategoryItem({super.key, required this.category, required this.onTap});

  final Map<String, dynamic> category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor = Color(category['color'] as int);
    final cardWidth = (28.w).clamp(108.0, 156.0);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: cardWidth,
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: categoryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: categoryColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: category['icon'] as String,
                color: categoryColor,
                size: 28,
              ),
            ),
            SizedBox(height: 1.h),
            Flexible(
              child: Text(
                category['name'] as String,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              '${category['count']} items',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

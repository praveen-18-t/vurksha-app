import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Empty cart state widget with illustration and CTA
class EmptyCartWidget extends StatelessWidget {
  const EmptyCartWidget({super.key, required this.onBrowseCategories});

  final VoidCallback onBrowseCategories;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty cart illustration
            CustomImageWidget(
              imageUrl:
                  'https://images.unsplash.com/photo-1607083206869-4c7672e72a8a?w=400',
              semanticLabel:
                  'Empty woven basket on white background representing empty shopping cart',
              width: 60.w,
              height: 30.h,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 4.h),

            // Empty cart message
            Text(
              'Your cart is empty',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),

            Text(
              'Start shopping for fresh organic produce from local farms',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),

            // Browse categories button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onBrowseCategories,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'grid_view',
                      size: 20,
                      color: theme.colorScheme.onPrimary,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Browse Categories',
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
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Product information widget with name, certification, and farm source
class ProductInfoWidget extends StatelessWidget {
  final String productName;
  final String farmSource;
  final bool isOrganic;

  const ProductInfoWidget({
    super.key,
    required this.productName,
    required this.farmSource,
    required this.isOrganic,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product name
          Text(
            productName,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: 1.h),

          // Certification and farm source
          Row(
            children: [
              if (isOrganic) ...[
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 0.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(1.h),
                    border: Border.all(
                      color: theme.colorScheme.primary,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: 'verified',
                        color: theme.colorScheme.primary,
                        size: 16,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        'Certified Organic',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 2.w),
              ],

              Expanded(
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'agriculture',
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 16,
                    ),
                    SizedBox(width: 1.w),
                    Expanded(
                      child: Text(
                        'From $farmSource',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

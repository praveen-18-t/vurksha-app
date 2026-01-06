import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Product description widget with expandable content
class ProductDescriptionWidget extends StatefulWidget {
  final String description;
  final String nutritionalBenefits;
  final String farmingPractices;

  const ProductDescriptionWidget({
    super.key,
    required this.description,
    required this.nutritionalBenefits,
    required this.farmingPractices,
  });

  @override
  State<ProductDescriptionWidget> createState() =>
      _ProductDescriptionWidgetState();
}

class _ProductDescriptionWidgetState extends State<ProductDescriptionWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About this product',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 1.h),

          // Description
          Text(
            widget.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
            maxLines: _isExpanded ? null : 3,
            overflow: _isExpanded ? null : TextOverflow.ellipsis,
          ),

          if (_isExpanded) ...[
            SizedBox(height: 2.h),

            // Nutritional benefits
            Text(
              'Nutritional Benefits',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              widget.nutritionalBenefits,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),

            SizedBox(height: 2.h),

            // Farming practices
            Text(
              'Farming Practices',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              widget.farmingPractices,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],

          SizedBox(height: 1.h),

          // Read more button
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isExpanded ? 'Read Less' : 'Read More',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 1.w),
                CustomIconWidget(
                  iconName: _isExpanded
                      ? 'keyboard_arrow_up'
                      : 'keyboard_arrow_down',
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

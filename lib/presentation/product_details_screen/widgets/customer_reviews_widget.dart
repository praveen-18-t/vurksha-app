import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Customer reviews widget with rating summary
class CustomerReviewsWidget extends StatefulWidget {
  final List<Map<String, dynamic>> reviews;
  final double averageRating;
  final int totalReviews;

  const CustomerReviewsWidget({
    super.key,
    required this.reviews,
    required this.averageRating,
    required this.totalReviews,
  });

  @override
  State<CustomerReviewsWidget> createState() => _CustomerReviewsWidgetState();
}

class _CustomerReviewsWidgetState extends State<CustomerReviewsWidget> {
  bool _showAllReviews = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayReviews = _showAllReviews
        ? widget.reviews
        : widget.reviews.take(3).toList();

    // Hide reviews section if there are no reviews
    if (widget.reviews.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer Reviews',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'No reviews yet. Be the first to review this product!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 2.h),
            OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Review writing feature coming soon!')),
                );
              },
              child: const Text('Write a Review'),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rating summary
          Row(
            children: [
              Text(
                'Customer Reviews',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              CustomIconWidget(iconName: 'star', color: Colors.amber, size: 20),
              SizedBox(width: 1.w),
              Text(
                '${widget.averageRating.toStringAsFixed(1)} (${widget.totalReviews})',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Reviews list
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayReviews.length,
            separatorBuilder: (context, index) => SizedBox(height: 2.h),
            itemBuilder: (context, index) {
              final review = displayReviews[index];
              return _buildReviewItem(context, theme, review);
            },
          ),

          if (widget.reviews.length > 3) ...[
            SizedBox(height: 2.h),
            InkWell(
              onTap: () {
                setState(() {
                  _showAllReviews = !_showAllReviews;
                });
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _showAllReviews ? 'Show Less' : 'View All Reviews',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 1.w),
                  CustomIconWidget(
                    iconName: _showAllReviews
                        ? 'keyboard_arrow_up'
                        : 'keyboard_arrow_down',
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ],

          SizedBox(height: 2.h),

          // Write review button
          OutlinedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Review writing feature coming soon!')),
              );
            },
            child: const Text('Write a Review'),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(
    BuildContext context,
    ThemeData theme,
    Map<String, dynamic> review,
  ) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(2.h),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 4.w,
                backgroundColor: theme.colorScheme.primary.withValues(
                  alpha: 0.1,
                ),
                child: Text(
                  (review['userName'] as String).substring(0, 1).toUpperCase(),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['userName'] as String,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (index) => CustomIconWidget(
                          iconName: index < (review['rating'] as int)
                              ? 'star'
                              : 'star_border',
                          color: Colors.amber,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                review['date'] as String,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),

          SizedBox(height: 1.h),

          Text(
            review['comment'] as String,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

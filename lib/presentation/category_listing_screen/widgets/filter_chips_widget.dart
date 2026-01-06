import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Horizontal filter chips with active count badges
class FilterChipsWidget extends StatelessWidget {
  const FilterChipsWidget({
    super.key,
    required this.activeFilters,
    required this.onFilterRemoved,
    required this.onFilterTap,
  });

  final Map<String, int> activeFilters;
  final ValueChanged<String> onFilterRemoved;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (activeFilters.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 6.h,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: activeFilters.length,
        separatorBuilder: (context, index) => SizedBox(width: 2.w),
        itemBuilder: (context, index) {
          final entry = activeFilters.entries.elementAt(index);
          return _buildFilterChip(context, theme, entry.key, entry.value);
        },
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    ThemeData theme,
    String label,
    int count,
  ) {
    return InkWell(
      onTap: () => onFilterRemoved(label),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (count > 0) ...[
              SizedBox(width: 1.w),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 1.5.w,
                  vertical: 0.3.h,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            SizedBox(width: 1.w),
            CustomIconWidget(
              iconName: 'close',
              color: theme.colorScheme.primary,
              size: 4.w,
            ),
          ],
        ),
      ),
    );
  }
}

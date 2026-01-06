import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Floating sort button that opens bottom sheet
class SortButtonWidget extends StatelessWidget {
  const SortButtonWidget({
    super.key,
    required this.onSortSelected,
    required this.currentSort,
  });

  final ValueChanged<String> onSortSelected;
  final String currentSort;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FloatingActionButton.extended(
      onPressed: () => _showSortOptions(context),
      backgroundColor: theme.colorScheme.primary,
      icon: CustomIconWidget(
        iconName: 'sort',
        color: theme.colorScheme.onPrimary,
        size: 5.w,
      ),
      label: Text(
        'Sort',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showSortOptions(BuildContext context) {
    final theme = Theme.of(context);
    final sortOptions = [
      {'label': 'Price: Low to High', 'value': 'price_asc'},
      {'label': 'Price: High to Low', 'value': 'price_desc'},
      {'label': 'Popularity', 'value': 'popularity'},
      {'label': 'Newest Arrivals', 'value': 'newest'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10.w,
                    height: 0.5.h,
                    margin: EdgeInsets.symmetric(vertical: 1.h),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Sort By', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                        IconButton(
                          icon: CustomIconWidget(iconName: 'close', color: theme.colorScheme.onSurface, size: 6.w),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  RadioGroup<String>(
                    groupValue: currentSort,
                    onChanged: (value) {
                      if (value == null) return;
                      setModalState(() {
                        onSortSelected(value);
                      });
                      Navigator.pop(context);
                    },
                    child: Column(
                      children: sortOptions.map((option) {
                        final isSelected = currentSort == option['value'];
                        return RadioListTile<String>(
                          value: option['value'] as String,
                          title: Text(
                            option['label'] as String,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 2.h),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

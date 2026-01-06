import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

/// Weight/size options selector widget
class WeightOptionsWidget extends StatefulWidget {
  final List<Map<String, dynamic>> weightOptions;
  final Function(Map<String, dynamic>) onWeightSelected;

  const WeightOptionsWidget({
    super.key,
    required this.weightOptions,
    required this.onWeightSelected,
  });

  @override
  State<WeightOptionsWidget> createState() => _WeightOptionsWidgetState();
}

class _WeightOptionsWidgetState extends State<WeightOptionsWidget> {
  int _selectedIndex = 0;

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
            'Select Weight',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 2.h),

          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: List.generate(widget.weightOptions.length, (index) {
              final option = widget.weightOptions[index];
              final isSelected = _selectedIndex == index;

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                  widget.onWeightSelected(option);
                  HapticFeedback.selectionClick();
                },
                borderRadius: BorderRadius.circular(2.h),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 1.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surface,
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(2.h),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        option['weight'] as String,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        '₹${(option['price'] as double).toStringAsFixed(2)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

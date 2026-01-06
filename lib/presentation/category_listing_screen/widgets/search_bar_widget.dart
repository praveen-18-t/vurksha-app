import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Search bar widget with real-time filtering capability
class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({
    super.key,
    required this.onSearchChanged,
    this.hintText = 'Search fresh products...',
  });

  final ValueChanged<String> onSearchChanged;
  final String hintText;

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    widget.onSearchChanged('');
    setState(() => _isSearching = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() => _isSearching = value.isNotEmpty);
          widget.onSearchChanged(value);
        },
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.all(3.w),
            child: CustomIconWidget(
              iconName: 'search',
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              size: 5.w,
            ),
          ),
          suffixIcon: _isSearching
              ? IconButton(
                  icon: CustomIconWidget(
                    iconName: 'clear',
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    size: 5.w,
                  ),
                  onPressed: _clearSearch,
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 4.w,
            vertical: 1.5.h,
          ),
        ),
      ),
    );
  }
}

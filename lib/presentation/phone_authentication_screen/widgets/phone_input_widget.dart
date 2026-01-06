import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Phone number input widget with Indian flag and +91 prefix
class PhoneInputWidget extends StatelessWidget {
  const PhoneInputWidget({
    super.key,
    required this.controller,
    this.onChanged,
    this.errorMessage,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorMessage != null
                  ? theme.colorScheme.error
                  : theme.colorScheme.outline.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              // Indian flag and country code
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Row(
                  children: [
                    Text('🇮🇳', style: TextStyle(fontSize: 20.sp)),
                    SizedBox(width: 2.w),
                    Text(
                      '+91',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Container(
                      width: 1,
                      height: 4.h,
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ],
                ),
              ),

              // Phone number input
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  maxLength: 10,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.5,
                  ),
                  decoration: InputDecoration(
                    hintText: '98765 43210',
                    hintStyle: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      letterSpacing: 1.5,
                    ),
                    border: InputBorder.none,
                    counterText: '',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 2.w,
                      vertical: 2.h,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Error message
        if (errorMessage != null) ...[
          SizedBox(height: 1.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'error_outline',
                  size: 16,
                  color: theme.colorScheme.error,
                ),
                SizedBox(width: 1.w),
                Expanded(
                  child: Text(
                    errorMessage!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

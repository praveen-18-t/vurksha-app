import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// OTP verification widget with 6-digit code input
class OtpVerificationWidget extends StatelessWidget {
  const OtpVerificationWidget({
    super.key,
    required this.controller,
    required this.onCompleted,
    this.errorMessage,
  });

  final TextEditingController controller;
  final VoidCallback onCompleted;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final defaultPinTheme = PinTheme(
      width: 12.w,
      height: 6.h,
      textStyle: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurface,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        border: Border.all(color: theme.colorScheme.primary, width: 2),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        border: Border.all(color: theme.colorScheme.error, width: 1.5),
      ),
    );

    return Column(
      children: [
        Pinput(
          controller: controller,
          length: 6,
          defaultPinTheme: errorMessage != null
              ? errorPinTheme
              : defaultPinTheme,
          focusedPinTheme: focusedPinTheme,
          onCompleted: (pin) => onCompleted(),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          hapticFeedbackType: HapticFeedbackType.lightImpact,
          autofocus: true,
        ),

        // Error message
        if (errorMessage != null) ...[
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'error_outline',
                size: 16,
                color: theme.colorScheme.error,
              ),
              SizedBox(width: 1.w),
              Text(
                errorMessage!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
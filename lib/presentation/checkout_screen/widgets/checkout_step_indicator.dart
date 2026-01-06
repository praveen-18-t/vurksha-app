import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Step indicator widget for checkout process
/// Shows visual progress through the multi-step checkout flow
class CheckoutStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Function(int)? onStepTapped;

  const CheckoutStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.onStepTapped,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outline, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Step indicators
          Row(
            children: List.generate(totalSteps, (index) {
              return Expanded(
                child: _buildStepItem(
                  context,
                  index,
                  theme,
                ),
              );
            }),
          ),
          
          // Step labels
          SizedBox(height: 1.h),
          Row(
            children: List.generate(totalSteps, (index) {
              return Expanded(
                child: _buildStepLabel(
                  context,
                  index,
                  theme,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  /// Build individual step item
  Widget _buildStepItem(BuildContext context, int index, ThemeData theme) {
    final stepNumber = index + 1;
    final isCompleted = index < currentStep;
    final isCurrent = index == currentStep;
    final isLast = index == totalSteps - 1;
    
    return Row(
      children: [
        // Step circle
        GestureDetector(
          onTap: onStepTapped != null && (index < currentStep || isCurrent)
              ? () => onStepTapped!(index)
              : null,
          child: Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted
                  ? theme.colorScheme.primary
                  : isCurrent
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
              border: isCurrent
                  ? Border.all(color: theme.colorScheme.primary, width: 2)
                  : null,
            ),
            child: Center(
              child: isCompleted
                  ? Icon(
                      Icons.check,
                      color: theme.colorScheme.onPrimary,
                      size: 4.w,
                    )
                  : Text(
                      stepNumber.toString(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isCurrent
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
        
        // Connector line
        if (!isLast)
          Expanded(
            child: Container(
              height: 2,
              margin: EdgeInsets.symmetric(horizontal: 1.w),
              color: isCompleted
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
            ),
          ),
      ],
    );
  }

  /// Build step label
  Widget _buildStepLabel(BuildContext context, int index, ThemeData theme) {
    final isCompleted = index < currentStep;
    final isCurrent = index == currentStep;
    
    final stepLabels = ['Summary', 'Address', 'Payment', 'Confirm'];
    
    return GestureDetector(
      onTap: onStepTapped != null && (index < currentStep || isCurrent)
          ? () => onStepTapped!(index)
          : null,
      child: Text(
        stepLabels[index],
        textAlign: TextAlign.center,
        style: theme.textTheme.bodySmall?.copyWith(
          color: isCompleted || isCurrent
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant,
          fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }
}

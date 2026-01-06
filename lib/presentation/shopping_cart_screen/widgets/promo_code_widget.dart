import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Promo code input widget with validation
class PromoCodeWidget extends StatefulWidget {
  const PromoCodeWidget({
    super.key,
    required this.onApply,
    this.appliedCode,
    required this.onRemove,
  });

  final Function(String) onApply;
  final String? appliedCode;
  final VoidCallback onRemove;

  @override
  State<PromoCodeWidget> createState() => _PromoCodeWidgetState();
}

class _PromoCodeWidgetState extends State<PromoCodeWidget> {
  final TextEditingController _promoController = TextEditingController();
  final FocusNode _promoFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.appliedCode != null) {
      _promoController.text = widget.appliedCode!;
    }
  }

  @override
  void dispose() {
    _promoController.dispose();
    _promoFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasAppliedCode = widget.appliedCode != null;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outline, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Have a promo code?',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),

          // Promo code input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _promoController,
                  focusNode: _promoFocusNode,
                  enabled: !hasAppliedCode,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: 'Enter promo code',
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(3.w),
                      child: CustomIconWidget(
                        iconName: 'local_offer',
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    suffixIcon: hasAppliedCode
                        ? IconButton(
                            onPressed: () {
                              _promoController.clear();
                              widget.onRemove();
                            },
                            icon: CustomIconWidget(
                              iconName: 'close',
                              size: 20,
                              color: theme.colorScheme.error,
                            ),
                            tooltip: 'Remove promo code',
                          )
                        : null,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.5.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.colorScheme.outline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.colorScheme.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.colorScheme.outline.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  style: theme.textTheme.bodyLarge,
                ),
              ),
              SizedBox(width: 2.w),

              // Apply button
              ElevatedButton(
                onPressed: hasAppliedCode
                    ? null
                    : () {
                        if (_promoController.text.trim().isNotEmpty) {
                          widget.onApply(_promoController.text.trim());
                          _promoFocusNode.unfocus();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 6.w,
                    vertical: 1.8.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Apply',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          // Applied code message
          if (hasAppliedCode) ...[
            SizedBox(height: 1.h),
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'check_circle',
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Promo code "${widget.appliedCode}" applied successfully',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Available promo codes hint
          if (!hasAppliedCode) ...[
            SizedBox(height: 1.h),
            Text(
              'Try: FRESH10, ORGANIC20, WELCOME50',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Price and quantity selector widget
class PriceQuantityWidget extends StatefulWidget {
  final double pricePerUnit;
  final String unit;
  final Function(int) onQuantityChanged;
  final int initialQuantity;

  const PriceQuantityWidget({
    super.key,
    required this.pricePerUnit,
    required this.unit,
    required this.onQuantityChanged,
    this.initialQuantity = 1,
  });

  @override
  State<PriceQuantityWidget> createState() => _PriceQuantityWidgetState();
}

class _PriceQuantityWidgetState extends State<PriceQuantityWidget> {
  late int _quantity;
  final TextEditingController _quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity;
    _quantityController.text = _quantity.toString();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _updateQuantity(int newQuantity) {
    if (newQuantity > 0 && newQuantity <= 99) {
      setState(() {
        _quantity = newQuantity;
        _quantityController.text = _quantity.toString();
      });
      widget.onQuantityChanged(_quantity);
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalPrice = widget.pricePerUnit * _quantity;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Price display
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '₹${totalPrice.toStringAsFixed(2)}',
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                '/ ${widget.unit}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Quantity selector
          Row(
            children: [
              Text(
                'Quantity:',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 3.w),

              // Minus button
              InkWell(
                onTap: () => _updateQuantity(_quantity - 1),
                borderRadius: BorderRadius.circular(1.h),
                child: Container(
                  width: 10.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.outline,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(1.h),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'remove',
                      color: theme.colorScheme.onSurface,
                      size: 20,
                    ),
                  ),
                ),
              ),

              SizedBox(width: 2.w),

              // Quantity input
              SizedBox(
                width: 15.w,
                height: 5.h,
                child: TextField(
                  controller: _quantityController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 1.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(1.h),
                      borderSide: BorderSide(color: theme.colorScheme.outline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(1.h),
                      borderSide: BorderSide(color: theme.colorScheme.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(1.h),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  onChanged: (value) {
                    final newQuantity = int.tryParse(value);
                    if (newQuantity != null) {
                      _updateQuantity(newQuantity);
                    }
                  },
                ),
              ),

              SizedBox(width: 2.w),

              // Plus button
              InkWell(
                onTap: () => _updateQuantity(_quantity + 1),
                borderRadius: BorderRadius.circular(1.h),
                child: Container(
                  width: 10.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.outline,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(1.h),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'add',
                      color: theme.colorScheme.onSurface,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

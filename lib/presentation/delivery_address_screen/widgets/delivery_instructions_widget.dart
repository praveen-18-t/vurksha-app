import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../data/models/address_model.dart';
import '../../../widgets/custom_icon_widget.dart';

class DeliveryInstructionsWidget extends StatefulWidget {
  final DeliveryInstructions instructions;
  final Function(DeliveryInstructions) onChanged;

  const DeliveryInstructionsWidget({
    super.key,
    required this.instructions,
    required this.onChanged,
  });

  @override
  State<DeliveryInstructionsWidget> createState() => _DeliveryInstructionsWidgetState();
}

class _DeliveryInstructionsWidgetState extends State<DeliveryInstructionsWidget> {
  late TextEditingController _specialNotesController;
  late TextEditingController _securityCodeController;
  late TextEditingController _preferredTimeController;

  @override
  void initState() {
    super.initState();
    _specialNotesController = TextEditingController(text: widget.instructions.specialNotes);
    _securityCodeController = TextEditingController(text: widget.instructions.securityCode);
    _preferredTimeController = TextEditingController(text: widget.instructions.preferredTimeSlot);

    _specialNotesController.addListener(_updateInstructions);
    _securityCodeController.addListener(_updateInstructions);
    _preferredTimeController.addListener(_updateInstructions);
  }

  @override
  void dispose() {
    _specialNotesController.dispose();
    _securityCodeController.dispose();
    _preferredTimeController.dispose();
    super.dispose();
  }

  void _updateInstructions() {
    final updatedInstructions = DeliveryInstructions(
      specialNotes: _specialNotesController.text,
      securityCode: _securityCodeController.text,
      preferredTimeSlot: _preferredTimeController.text,
    );
    widget.onChanged(updatedInstructions);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CustomIconWidget(
                iconName: 'delivery_dining',
                color: theme.colorScheme.primary,
                size: 4.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Delivery Instructions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                'Optional',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Special delivery notes
          Text(
            'Special Delivery Notes',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 0.5.h),
          TextFormField(
            controller: _specialNotesController,
            decoration: InputDecoration(
              hintText: 'e.g., Ring doorbell twice, leave at reception, call before delivery',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
            ),
            maxLines: 3,
            minLines: 1,
          ),

          SizedBox(height: 2.h),

          // Security code
          Text(
            'Security Code / Gate Code',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 0.5.h),
          TextFormField(
            controller: _securityCodeController,
            decoration: InputDecoration(
              hintText: 'Enter security or gate code (if applicable)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
              prefixIcon: const Icon(Icons.lock),
            ),
            obscureText: true,
          ),

          SizedBox(height: 2.h),

          // Preferred delivery time slot
          Text(
            'Preferred Delivery Time',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 0.5.h),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: theme.dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // Quick time slot buttons
                Padding(
                  padding: EdgeInsets.all(2.w),
                  child: Wrap(
                    spacing: 2.w,
                    runSpacing: 1.h,
                    children: [
                      _buildTimeSlotChip('9 AM - 12 PM', theme),
                      _buildTimeSlotChip('12 PM - 3 PM', theme),
                      _buildTimeSlotChip('3 PM - 6 PM', theme),
                      _buildTimeSlotChip('6 PM - 9 PM', theme),
                    ],
                  ),
                ),
                // Custom time input
                Padding(
                  padding: EdgeInsets.fromLTRB(2.w, 0, 2.w, 2.w),
                  child: TextFormField(
                    controller: _preferredTimeController,
                    decoration: InputDecoration(
                      hintText: 'Or enter custom time preference',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 1.w),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 1.h),

          // Help text
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'info',
                  color: theme.colorScheme.primary,
                  size: 3.w,
                ),
                SizedBox(width: 1.w),
                Expanded(
                  child: Text(
                    'These instructions help our delivery partners find and deliver your order efficiently',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotChip(String timeSlot, ThemeData theme) {
    final isSelected = _preferredTimeController.text == timeSlot;
    
    return InkWell(
      onTap: () {
        _preferredTimeController.text = isSelected ? '' : timeSlot;
        _updateInstructions();
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.dividerColor,
          ),
        ),
        child: Text(
          timeSlot,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

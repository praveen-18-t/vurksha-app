import 'package:flutter/material.dart';

/// Delivery Time Slot Widget
class DeliveryTimeSlotWidget extends StatelessWidget {
  final String? selectedSlot;
  final List<String> availableSlots;
  final Function(String)? onSlotSelected;

  const DeliveryTimeSlotWidget({
    super.key,
    this.selectedSlot,
    this.availableSlots = const [
      '9:00 AM - 11:00 AM',
      '11:00 AM - 1:00 PM',
      '2:00 PM - 4:00 PM',
      '4:00 PM - 6:00 PM',
      '6:00 PM - 8:00 PM',
    ],
    this.onSlotSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery Time Slot',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text('Choose your preferred delivery time'),
          const Text('Select a 2-hour time slot for same-day delivery'),
        ],
      ),
    );
  }
}

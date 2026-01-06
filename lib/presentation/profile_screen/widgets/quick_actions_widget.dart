import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionItem(context, Icons.replay, 'Reorder'),
              _buildActionItem(context, Icons.favorite_border, 'Wishlist'),
              _buildActionItem(context, Icons.track_changes, 'Track Order'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$label coming soon!')),
            );
          },
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: EdgeInsets.all(4.w),
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
          child: Icon(icon, size: 6.w),
        ),
        SizedBox(height: 1.h),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

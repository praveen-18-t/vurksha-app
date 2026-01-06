import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class MembershipRewardsWidget extends StatelessWidget {
  final String membershipTier;
  final int loyaltyPoints;
  final int pointsToNextTier;

  const MembershipRewardsWidget({
    super.key,
    required this.membershipTier,
    required this.loyaltyPoints,
    required this.pointsToNextTier,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = loyaltyPoints / pointsToNextTier;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(1.5.h),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Membership & Rewards',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(membershipTier, style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
              Text('$loyaltyPoints Points', style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.secondary, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 1.h),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          ),
          SizedBox(height: 1.h),
          Text(
            '${pointsToNextTier - loyaltyPoints} points to the next tier',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class VerificationStatusWidget extends StatelessWidget {
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final bool isKycVerified;

  const VerificationStatusWidget({
    super.key,
    required this.isEmailVerified,
    required this.isPhoneVerified,
    required this.isKycVerified,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(3.w),
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
            'Verification Status',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 1.5.h),
          _buildVerificationItem(context, 'Email', isEmailVerified, Icons.email),
          _buildVerificationItem(context, 'Phone', isPhoneVerified, Icons.phone),
          _buildVerificationItem(context, 'Identity (KYC)', isKycVerified, Icons.verified_user),
        ],
      ),
    );
  }

  Widget _buildVerificationItem(BuildContext context, String title, bool isVerified, IconData icon) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        children: [
          Icon(
            isVerified ? Icons.verified : Icons.pending,
            color: isVerified ? Colors.green : Colors.orange,
            size: 4.w,
          ),
          SizedBox(width: 2.w),
          Icon(
            icon,
            size: 3.w,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          SizedBox(width: 2.w),
          Text(title, style: theme.textTheme.bodyMedium),
          const Spacer(),
          Text(
            isVerified ? 'Verified' : 'Not Verified',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isVerified ? Colors.green : Colors.orange,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

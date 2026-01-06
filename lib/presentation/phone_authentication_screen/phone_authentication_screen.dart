import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../data/repositories/auth_repository.dart';
import '../../core/api/api_client.dart';
import './widgets/otp_verification_widget.dart';
import './widgets/phone_input_widget.dart';

/// Phone Authentication Screen for OTP-based login
/// Implements Firebase Authentication optimized for Indian mobile users
class PhoneAuthenticationScreen extends StatefulWidget {
  const PhoneAuthenticationScreen({super.key});

  @override
  State<PhoneAuthenticationScreen> createState() =>
      _PhoneAuthenticationScreenState();
}

class _PhoneAuthenticationScreenState extends State<PhoneAuthenticationScreen> {
  final AuthRepository _authRepository = AuthRepository();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isOtpSent = false;
  bool _isLoading = false;
  String? _errorMessage;
  int _resendCountdown = 30;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  /// Validates 10-digit Indian phone number
  bool _validatePhoneNumber(String phone) {
    final phoneRegex = RegExp(r'^[6-9]\d{9}$');
    return phoneRegex.hasMatch(phone);
  }

  /// Sends OTP via Backend API
  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();

    if (!_validatePhoneNumber(phone)) {
      setState(() {
        _errorMessage = 'Please enter a valid 10-digit mobile number';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authRepository.sendOtp(phone);

      if (mounted) {
        setState(() {
          _isLoading = false;
          _isOtpSent = true;
          _startResendCountdown();
        });
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
    final phone = _phoneController.text.trim();

    if (otp.length != 6) {
      setState(() {
        _errorMessage = 'Please enter a valid 6-digit OTP';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authRepository.verifyOtp(phone, otp);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        HapticFeedback.mediumImpact();
        
        // Navigate to home screen
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.home, // Navigate to home directly after login
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }
    // Haptic feedback
    HapticFeedback.mediumImpact();

    // Navigate to home screen
    if (mounted) {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.userDetails,
      );
    }
  }

  /// Starts resend OTP countdown timer
  void _startResendCountdown() {
    _resendCountdown = 30;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _resendCountdown--;
        });
      }
      return _resendCountdown > 0 && mounted;
    });
  }

  /// Resends OTP with haptic feedback
  Future<void> _resendOtp() async {
    if (_resendCountdown > 0) return;

    HapticFeedback.lightImpact();
    await _sendOtp();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 6.h),

                // Organic farm logo
                SizedBox(
                  width: 30.w,
                  height: 30.w,
                  child: Image.asset(
                    'assets/images/vurksha_logo.png',
                    fit: BoxFit.contain,
                    semanticLabel: 'Vurksha logo',
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.eco_rounded,
                        color: theme.colorScheme.primary,
                        size: 30,
                      );
                    },
                  ),
                ),

                SizedBox(height: 4.h),

                // Welcome message
                Text(
                  'Fresh produce delivered\nto your doorstep',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),

                SizedBox(height: 2.h),

                Text(
                  _isOtpSent
                      ? 'Enter the 6-digit code sent to\n+91 ${_phoneController.text}'
                      : 'Enter your mobile number to get started',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),

                SizedBox(height: 6.h),

                // Phone input or OTP verification
                _isOtpSent
                    ? OtpVerificationWidget(
                        controller: _otpController,
                        onCompleted: _verifyOtp,
                        errorMessage: _errorMessage,
                      )
                    : PhoneInputWidget(
                        controller: _phoneController,
                        onChanged: (value) {
                          if (_errorMessage != null) {
                            setState(() {
                              _errorMessage = null;
                            });
                          }
                        },
                        errorMessage: _errorMessage,
                      ),

                SizedBox(height: 4.h),

                // Action button
                SizedBox(
                  width: double.infinity,
                  height: 6.h,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : (_isOtpSent ? _verifyOtp : _sendOtp),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 3.h,
                            height: 3.h,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.onPrimary,
                              ),
                            ),
                          )
                        : Text(
                            _isOtpSent ? 'Verify OTP' : 'Send OTP',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                // Resend OTP option
                if (_isOtpSent) ...[
                  SizedBox(height: 3.h),
                  TextButton(
                    onPressed: _resendCountdown > 0 ? null : _resendOtp,
                    child: Text(
                      _resendCountdown > 0
                          ? 'Resend OTP in ${_resendCountdown}s'
                          : 'Resend OTP',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: _resendCountdown > 0
                            ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                            : theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],

                SizedBox(height: 4.h),

                // Back to phone input
                if (_isOtpSent)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _isOtpSent = false;
                        _otpController.clear();
                        _errorMessage = null;
                      });
                    },
                    icon: CustomIconWidget(
                      iconName: 'arrow_back',
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                    label: Text(
                      'Change phone number',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

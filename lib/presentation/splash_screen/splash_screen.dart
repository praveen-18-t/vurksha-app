import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';

/// Splash Screen - Branded app launch experience with service initialization
///
/// Displays full-screen organic farm branding while performing critical background tasks:
/// - Firebase authentication status check
/// - User preferences loading from MongoDB
/// - Product categories fetching
/// - Cart data preparation
///
/// Navigation logic:
/// - Authenticated users → Home screen
/// - New users → Onboarding flow
/// - Returning non-authenticated users → Phone Authentication screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  final bool _isInitializing = true;
  bool _hasError = false;
  String _statusMessage = 'Loading fresh produce...';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  /// Setup logo animations with subtle scale and fade effects
  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  /// Initialize app services and determine navigation route
  Future<void> _initializeApp() async {
    try {
      // Simulate critical service initialization
      // In production: Firebase auth check, MongoDB preferences, category fetch, cart prep
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // Check authentication status (simulated)
      final bool isAuthenticated = await _checkAuthenticationStatus();
      final bool isFirstLaunch = await _checkFirstLaunch();

      // Add smooth transition delay
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      // Navigate based on user status
      if (isAuthenticated) {
        _navigateToHome();
      } else if (isFirstLaunch) {
        _navigateToOnboarding();
      } else {
        _navigateToAuthentication();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _statusMessage = 'Connection issue. Tap to retry';
      });

      // Auto-retry after 5 seconds
      Timer(const Duration(seconds: 5), () {
        if (mounted && _hasError) {
          _retryInitialization();
        }
      });
    }
  }

  /// Check Firebase authentication status (simulated)
  Future<bool> _checkAuthenticationStatus() async {
    // In production: Check Firebase auth state
    await Future.delayed(const Duration(milliseconds: 500));
    return false; // Simulated: user not authenticated
  }

  /// Check if this is first app launch (simulated)
  Future<bool> _checkFirstLaunch() async {
    // In production: Check SharedPreferences for first launch flag
    await Future.delayed(const Duration(milliseconds: 300));
    return false; // Simulated: not first launch
  }

  /// Retry initialization on error
  void _retryInitialization() {
    setState(() {
      _hasError = false;
      _statusMessage = 'Loading fresh produce...';
    });
    _initializeApp();
  }

  /// Navigate to home screen (authenticated users)
  void _navigateToHome() {
    Navigator.pushReplacementNamed(context, '/home-screen');
  }

  /// Navigate to onboarding flow (new users)
  void _navigateToOnboarding() {
    // In production: Navigate to onboarding screen
    // For now, redirect to authentication
    _navigateToAuthentication();
  }

  /// Navigate to phone authentication screen
  void _navigateToAuthentication() {
    Navigator.pushReplacementNamed(context, '/phone-authentication-screen');
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    // Set status bar style based on theme
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness == Brightness.light
            ? Brightness.light
            : Brightness.dark,
      ),
    );

    return Scaffold(
      body: GestureDetector(
        onTap: _hasError ? _retryInitialization : null,
        child: Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primaryContainer,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Animated logo section
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  child: _buildLogoSection(theme),
                ),

                const Spacer(flex: 2),

                // Loading indicator and status message
                _buildLoadingSection(theme),

                SizedBox(height: 8.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build logo section with organic farm branding
  Widget _buildLogoSection(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo icon
        Container(
          width: 30.w,
          height: 30.w,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: 'eco',
              size: 15.w,
              color: Colors.white,
            ),
          ),
        ),

        SizedBox(height: 3.h),

        // App name
        Text(
          'Vurksha',
          style: theme.textTheme.headlineLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),

        SizedBox(height: 1.h),

        // Tagline
        Text(
          'Farm Fresh to Your Home',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  /// Build loading indicator and status message section
  Widget _buildLoadingSection(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Loading indicator or error icon
        _hasError
            ? CustomIconWidget(
                iconName: 'refresh',
                size: 8.w,
                color: Colors.white.withValues(alpha: 0.9),
              )
            : SizedBox(
                width: 8.w,
                height: 8.w,
                child: CircularProgressIndicator(
                  strokeWidth: 3.0,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ),

        SizedBox(height: 2.h),

        // Status message
        Text(
          _statusMessage,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

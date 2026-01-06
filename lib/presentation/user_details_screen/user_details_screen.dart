import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import '../../notifications/notification_controller.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_app_bar.dart';

class UserDetailsScreen extends ConsumerStatefulWidget {
  const UserDetailsScreen({super.key});

  static const String prefsKeyName = 'user_full_name';
  static const String prefsKeyEmail = 'user_email';

  @override
  ConsumerState<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends ConsumerState<UserDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prefs = ref.read(sharedPreferencesProvider);
      final name = prefs.getString(UserDetailsScreen.prefsKeyName) ?? '';
      final email = prefs.getString(UserDetailsScreen.prefsKeyEmail) ?? '';

      if (name.trim().isNotEmpty && email.trim().isNotEmpty) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
        return;
      }

      if (name.trim().isNotEmpty) {
        _nameController.text = name;
      }
      if (email.trim().isNotEmpty) {
        _emailController.text = email;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Please enter your name';
    if (v.length < 2) return 'Name is too short';
    return null;
  }

  String? _validateEmail(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Please enter your email';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(v)) return 'Please enter a valid email';
    return null;
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isSaving = true;
    });

    final prefs = ref.read(sharedPreferencesProvider);
    await Future.wait<void>([
      prefs.setString(UserDetailsScreen.prefsKeyName, _nameController.text.trim()),
      prefs.setString(UserDetailsScreen.prefsKeyEmail, _emailController.text.trim()),
    ]);

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        variant: AppBarVariant.standard,
        title: const Text('Your Details'),
        showBackButton: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tell us about you',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 1.h),
                Text(
                  'This helps us personalize your experience.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                SizedBox(height: 4.h),
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: _validateName,
                ),
                SizedBox(height: 2.h),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: _validateEmail,
                  onFieldSubmitted: (_) => _isSaving ? null : _save(),
                ),
                SizedBox(height: 4.h),
                SizedBox(
                  width: double.infinity,
                  height: 6.h,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const CircularProgressIndicator()
                        : const Text('Continue'),
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

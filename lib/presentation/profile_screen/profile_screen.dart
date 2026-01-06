import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../../widgets/custom_app_bar.dart';
import 'widgets/profile_header_widget.dart';
import 'widgets/profile_menu_widget.dart';

/// Profile Screen - User profile information and settings
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // User data state
  Map<String, dynamic> userData = {
    'name': 'John Doe',
    'email': 'john.doe@example.com',
    'phone': '+91 98765 43210',
    'memberSince': 'Nov 2023',
    'avatar': null,
    'isEmailVerified': true,
    'isPhoneVerified': true,
    'isKycVerified': false,
    'membershipTier': 'Gold',
    'loyaltyPoints': 1250,
    'pointsToNextTier': 2000,
    'totalOrders': 47,
    'totalSpent': 15420.50,
    'averageOrderValue': 328.09,
    'isTwoFactorEnabled': false,
    'marketingEmails': true,
    'smsNotifications': false,
    'pushNotifications': true,
    'defaultAddress': '123 Green Valley, Farmville, 560100',
    'defaultPaymentMethod': 'Visa **** 1234',
  };

  // Method to update user data
  void _updateUserData(Map<String, dynamic> newData) {
    setState(() {
      userData = {...userData, ...newData};
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        variant: AppBarVariant.standard,
        title: Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            ProfileHeaderWidget(
              userData: userData,
              onEditProfile: () => _showEditProfileDialog(context),
              onAvatarTap: () => _showImageSourceActionSheet(context),
            ),
            
            // Profile Menu Items
            ProfileMenuWidget(
              userData: userData,
              onUserDataUpdated: _updateUserData,
            ),
            
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final theme = Theme.of(context);
    final nameController = TextEditingController(text: userData['name']);
    final emailController = TextEditingController(text: userData['email']);
    final phoneController = TextEditingController(text: userData['phone']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Edit Profile',
          style: theme.textTheme.titleLarge,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _updateUserData({
                'name': nameController.text,
                'email': emailController.text,
                'phone': phoneController.text,
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated successfully')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Photo Library'),
              onTap: () {
                _pickImage(ImageSource.gallery);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Camera'),
              onTap: () {
                _pickImage(ImageSource.camera);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      setState(() {
        userData['avatar'] = image.path;
      });
    }
  }
}

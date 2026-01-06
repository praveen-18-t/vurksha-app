import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../../data/models/user_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ProfileManagementScreen extends StatefulWidget {
  final UserModel user;

  const ProfileManagementScreen({super.key, required this.user});

  @override
  State<ProfileManagementScreen> createState() => _ProfileManagementScreenState();
}

class _ProfileManagementScreenState extends State<ProfileManagementScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phoneNumber);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _pickedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to pick image')),
        );
      }
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      // In a real app, you would save the updated user data to a backend service.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Management'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildAvatar(theme),
              SizedBox(height: 4.h),
              CustomTextField(
                controller: _nameController,
                labelText: 'Full Name',
                prefixIcon: Icons.person_outline,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your name' : null,
              ),
              SizedBox(height: 2.h),
              CustomTextField(
                controller: _emailController,
                labelText: 'Email Address',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your email' : null,
              ),
              SizedBox(height: 2.h),
              CustomTextField(
                controller: _phoneController,
                labelText: 'Phone Number',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your phone number' : null,
              ),
              SizedBox(height: 4.h),
              CustomButton(
                text: 'Save Changes',
                onPressed: _saveProfile,
              ),
              SizedBox(height: 2.h),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Change password feature coming soon!')),
                  );
                },
                child: const Text('Change Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme) {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 12.w,
            backgroundImage: _pickedImage != null
                ? FileImage(_pickedImage!) as ImageProvider
                : widget.user.profilePictureUrl.isNotEmpty
                    ? NetworkImage(widget.user.profilePictureUrl)
                    : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
            backgroundColor: theme.colorScheme.surface,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: IconButton(
                icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return SafeArea(
                        child: Wrap(
                          children: <Widget>[
                            ListTile(
                              leading: const Icon(Icons.photo_library),
                              title: const Text('Choose from Gallery'),
                              onTap: () {
                                _pickImage(ImageSource.gallery);
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.camera_alt),
                              title: const Text('Take a Photo'),
                              onTap: () {
                                _pickImage(ImageSource.camera);
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

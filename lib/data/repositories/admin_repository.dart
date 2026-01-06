import '../models/admin_user_model.dart';

class AdminRepository {
  // Mock database
  final List<AdminUser> _adminUsers = [
    AdminUser(id: 'U1', name: 'Admin User', email: 'admin@example.com', role: 'Super Admin'),
    AdminUser(id: 'U2', name: 'Manager User', email: 'manager@example.com', role: 'Manager'),
    AdminUser(id: 'U3', name: 'Support User', email: 'support@example.com', role: 'Support'),
  ];

  final List<String> _activityLogs = [
    'Admin User logged in.',
    'Manager User updated product #PROD102.',
    'Support User resolved ticket #T567.',
  ];

  // Get all admin users
  Future<List<AdminUser>> getAdminUsers() async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay
    return _adminUsers;
  }

  // Add a new admin user
  Future<void> addAdminUser(AdminUser user) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _adminUsers.add(user);
  }

  // Update an admin user's role
  Future<void> updateAdminUserRole(String userId, String newRole) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _adminUsers.indexWhere((u) => u.id == userId);
    if (index != -1) {
      final user = _adminUsers[index];
      _adminUsers[index] = AdminUser(id: user.id, name: user.name, email: user.email, role: newRole);
    }
  }

  // Delete an admin user
  Future<void> deleteAdminUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _adminUsers.removeWhere((u) => u.id == userId);
  }

  // Get activity logs
  Future<List<String>> getActivityLogs() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _activityLogs;
  }
}

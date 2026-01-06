import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../../data/models/admin_user_model.dart';
import '../../../../data/repositories/admin_repository.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final AdminRepository _adminRepository = AdminRepository();
  late Future<List<AdminUser>> _adminUsersFuture;
  late Future<List<String>> _activityLogsFuture;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    setState(() {
      _adminUsersFuture = _adminRepository.getAdminUsers();
      _activityLogsFuture = _adminRepository.getActivityLogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Security & Access Control', style: theme.textTheme.headlineMedium),
            SizedBox(height: 4.h),
            _buildSection(context, 'Admin Users', _buildFutureBuilder(_adminUsersFuture, _buildUsersTable)),
            SizedBox(height: 4.h),
            _buildSection(context, 'Activity Logs', _buildFutureBuilder(_activityLogsFuture, _buildLogsList)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditUserDialog(context),
        tooltip: 'Add Admin User',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFutureBuilder<T>(Future<T> future, Widget Function(T data) builder) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('No data found.'));
        }
        return builder(snapshot.data as T);
      },
    );
  }

  Widget _buildSection(BuildContext context, String title, Widget content) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(title, style: theme.textTheme.titleLarge), const Divider(), content],
        ),
      ),
    );
  }

  Widget _buildUsersTable(List<AdminUser> users) {
    return DataTable(
      columns: const [DataColumn(label: Text('Name')), DataColumn(label: Text('Role')), DataColumn(label: Text('Actions'))],
      rows: users.map((user) => DataRow(
        cells: [
          DataCell(Text(user.name)),
          DataCell(Text(user.role)),
          DataCell(Row(
            children: [
              IconButton(icon: Icon(Icons.edit, size: 4.w), onPressed: () => _showAddEditUserDialog(context, user: user)),
              IconButton(icon: Icon(Icons.delete, size: 4.w, color: Colors.red), onPressed: () => _deleteUser(user.id)),
            ],
          )),
        ],
      )).toList(),
    );
  }

  Widget _buildLogsList(List<String> logs) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: logs.length,
      itemBuilder: (context, index) => ListTile(leading: const Icon(Icons.history), title: Text(logs[index])),
    );
  }

  Future<void> _deleteUser(String userId) async {
    await _adminRepository.deleteAdminUser(userId);
    _fetchData();
  }

  void _showAddEditUserDialog(BuildContext context, {AdminUser? user}) {
    final isEditing = user != null;
    final formKey = GlobalKey<FormState>();
    String name = isEditing ? user.name : '';
    String email = isEditing ? user.email : '';
    String role = isEditing ? user.role : 'Support';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit User' : 'Add User'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(initialValue: name, decoration: const InputDecoration(labelText: 'Name'), validator: (val) => val!.isEmpty ? 'Required' : null, onSaved: (val) => name = val!),
              TextFormField(initialValue: email, decoration: const InputDecoration(labelText: 'Email'), validator: (val) => val!.isEmpty ? 'Required' : null, onSaved: (val) => email = val!),
              DropdownButtonFormField<String>(
                initialValue: role,
                items: ['Super Admin', 'Manager', 'Support'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                onChanged: (val) => setState(() => role = val!),
                decoration: const InputDecoration(labelText: 'Role'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                if (isEditing) {
                  await _adminRepository.updateAdminUserRole(user.id, role);
                } else {
                  final newUser = AdminUser(id: 'U${DateTime.now().millisecond}', name: name, email: email, role: role);
                  await _adminRepository.addAdminUser(newUser);
                }
                _fetchData();
                if (!context.mounted) return;
                Navigator.pop(context);
              }
            },
            child: Text(isEditing ? 'Save' : 'Add'),
          ),
        ],
      ),
    );
  }
}

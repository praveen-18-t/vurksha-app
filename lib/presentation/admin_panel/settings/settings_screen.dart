import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../../data/models/admin_settings_model.dart';
import '../../../../data/repositories/admin_settings_repository.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AdminSettingsRepository _settingsRepository = AdminSettingsRepository();
  late Future<AdminSettingsModel> _settingsFuture;
  final _formKey = GlobalKey<FormState>();

  // State variables
  bool _storeOpen = true;
  bool _codEnabled = true;
  bool _stripeEnabled = true;
  late TextEditingController _deliveryRadiusController;

  @override
  void initState() {
    super.initState();
    _settingsFuture = _settingsRepository.getSettings().then((settings) {
      _storeOpen = settings.storeOpen;
      _codEnabled = settings.codEnabled;
      _stripeEnabled = settings.stripeEnabled;
      _deliveryRadiusController = TextEditingController(text: settings.deliveryRadius.toString());
      return settings;
    });
  }

  @override
  void dispose() {
    _deliveryRadiusController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newSettings = AdminSettingsModel(
        storeOpen: _storeOpen,
        deliveryRadius: double.parse(_deliveryRadiusController.text),
        codEnabled: _codEnabled,
        stripeEnabled: _stripeEnabled,
      );
      await _settingsRepository.saveSettings(newSettings);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: FutureBuilder<AdminSettingsModel>(
        future: _settingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(4.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Settings & Configuration', style: theme.textTheme.headlineMedium),
                  SizedBox(height: 4.h),
                  _buildSection(context, 'Store Settings', [
                    SwitchListTile(title: const Text('Store Open'), value: _storeOpen, onChanged: (val) => setState(() => _storeOpen = val)),
                    _buildTextField('Delivery Radius (km)', _deliveryRadiusController),
                  ]),
                  _buildSection(context, 'Payment Gateways', [
                    SwitchListTile(title: const Text('Cash on Delivery (COD)'), value: _codEnabled, onChanged: (val) => setState(() => _codEnabled = val)),
                    SwitchListTile(title: const Text('Stripe'), value: _stripeEnabled, onChanged: (val) => setState(() => _stripeEnabled = val)),
                  ]),
                  SizedBox(height: 4.h),
                  Center(child: ElevatedButton(onPressed: _saveSettings, child: const Text('Save Settings'))),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.only(bottom: 3.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(title, style: theme.textTheme.titleLarge), const Divider(), ...children],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 4.w),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.isEmpty || double.tryParse(value) == null) {
            return 'Please enter a valid number';
          }
          return null;
        },
      ),
    );
  }
}

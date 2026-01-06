import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Text(
                    'Vurksha Rocket',
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Version 1.0.0',
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            SizedBox(height: 4.h),
            ListTile(
              title: const Text('Terms of Service'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Terms of Service will open in browser')),
                );
              },
            ),
            ListTile(
              title: const Text('Privacy Policy'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Privacy Policy will open in browser')),
                );
              },
            ),
            ListTile(
              title: const Text('Open Source Licenses'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Open source licenses coming soon!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

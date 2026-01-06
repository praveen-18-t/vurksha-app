import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../../../data/repositories/report_repository.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final ReportRepository _reportRepository = ReportRepository();
  bool _isExporting = false;

  final List<Map<String, String>> _reports = const [
    {'title': 'Sales Report', 'description': 'Daily, weekly, and monthly sales data.'},
    {'title': 'Inventory Report', 'description': 'Current stock levels and valuation.'},
    // Add other reports back once their repositories are created
  ];

  Future<void> _exportReport(String title) async {
    setState(() => _isExporting = true);
    try {
      String csvData;
      String fileName;

      switch (title) {
        case 'Sales Report':
          csvData = await _reportRepository.generateSalesReport();
          fileName = 'sales_report.csv';
          break;
        case 'Inventory Report':
          csvData = await _reportRepository.generateInventoryReport();
          fileName = 'inventory_report.csv';
          break;
        default:
          throw Exception('Unknown report type');
      }

      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/$fileName';
      final file = File(path);
      await file.writeAsString(csvData);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(path)],
          text: 'Here is the $title',
        ),
      );

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export report: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isExporting = false);
    }
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
            Text('Reports & Exports', style: theme.textTheme.headlineMedium),
            SizedBox(height: 4.h),
            if (_isExporting) const Center(child: CircularProgressIndicator()),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _reports.length,
              itemBuilder: (context, index) {
                final report = _reports[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 2.w),
                  child: ListTile(
                    title: Text(report['title']!),
                    subtitle: Text(report['description']!),
                    trailing: ElevatedButton(
                      onPressed: _isExporting ? null : () => _exportReport(report['title']!),
                      child: const Text('Export'),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

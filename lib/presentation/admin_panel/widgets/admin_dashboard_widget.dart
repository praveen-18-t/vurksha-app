import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sizer/sizer.dart';

class AdminDashboardWidget extends StatefulWidget {
  const AdminDashboardWidget({super.key});

  @override
  State<AdminDashboardWidget> createState() => _AdminDashboardWidgetState();
}

class _AdminDashboardWidgetState extends State<AdminDashboardWidget> {
  // Mock data for the dashboard
  final Map<String, dynamic> _kpiData = {
    'total_sales': 125000.0,
    'new_orders': 45,
    'new_customers': 12,
    'pending_deliveries': 8,
  };

  final List<Map<String, dynamic>> _recentActivities = [
    {'icon': Icons.shopping_cart, 'title': 'New order #12345', 'time': '5m ago'},
    {'icon': Icons.person_add, 'title': 'New customer registered', 'time': '15m ago'},
    {'icon': Icons.payment, 'title': 'Payment received for #12344', 'time': '30m ago'},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildKpiSection(context),
          SizedBox(height: 4.h),
          _buildSalesChart(context),
          SizedBox(height: 4.h),
          _buildRecentActivities(context),
        ],
      ),
    );
  }

  Widget _buildKpiSection(BuildContext context) {
    final theme = Theme.of(context);
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 4.w,
      mainAxisSpacing: 4.w,
      childAspectRatio: 1.5,
      children: [
        _buildKpiCard(context, 'Total Sales', '₹${_kpiData['total_sales']}', Icons.monetization_on, theme.colorScheme.primary),
        _buildKpiCard(context, 'New Orders', '${_kpiData['new_orders']}', Icons.shopping_cart, theme.colorScheme.secondary),
        _buildKpiCard(context, 'New Customers', '${_kpiData['new_customers']}', Icons.person_add, theme.colorScheme.tertiary),
        _buildKpiCard(context, 'Pending Deliveries', '${_kpiData['pending_deliveries']}', Icons.local_shipping, theme.colorScheme.error),
      ],
    );
  }

  Widget _buildKpiCard(BuildContext context, String title, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(3.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 6.w, color: color),
            Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            Text(title, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesChart(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sales Trend', style: theme.textTheme.titleLarge),
            SizedBox(height: 2.h),
            SizedBox(
              height: 30.h,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 3), FlSpot(1, 1), FlSpot(2, 4), FlSpot(3, 2), FlSpot(4, 5),
                      ],
                      isCurved: true,
                      color: theme.colorScheme.primary,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(show: true, color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivities(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent Activities', style: theme.textTheme.titleLarge),
            SizedBox(height: 2.h),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentActivities.length,
              itemBuilder: (context, index) {
                final activity = _recentActivities[index];
                return ListTile(
                  leading: Icon(activity['icon'], color: theme.colorScheme.secondary),
                  title: Text(activity['title']),
                  trailing: Text(activity['time']),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

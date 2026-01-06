import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../../data/models/support_ticket_model.dart';
import '../../../../data/repositories/support_repository.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final SupportRepository _supportRepository = SupportRepository();
  late Future<List<SupportTicket>> _ticketsFuture;
  List<SupportTicket> _allTickets = [];
  List<SupportTicket> _filteredTickets = [];
  String _selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    _fetchTickets();
  }

  void _fetchTickets() {
    setState(() {
      _ticketsFuture = _supportRepository.getSupportTickets();
    });
  }

  void _filterTickets(String status) {
    setState(() {
      _selectedStatus = status;
      if (status == 'All') {
        _filteredTickets = _allTickets;
      } else {
        _filteredTickets = _allTickets.where((ticket) => ticket.status == status).toList();
      }
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
            Text('Support Tickets', style: theme.textTheme.headlineMedium),
            SizedBox(height: 2.h),
            _buildFilterChips(context),
            SizedBox(height: 2.h),
            FutureBuilder<List<SupportTicket>>(
              future: _ticketsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No tickets found.'));
                }
                _allTickets = snapshot.data!;
                _filterTickets(_selectedStatus);
                return _buildTicketsList(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ['All', 'Open', 'In Progress', 'Closed'].map((status) {
          return Padding(
            padding: EdgeInsets.only(right: 2.w),
            child: FilterChip(
              label: Text(status),
              selected: _selectedStatus == status,
              onSelected: (selected) => _filterTickets(status),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTicketsList(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredTickets.length,
      itemBuilder: (context, index) {
        final ticket = _filteredTickets[index];
        return Card(
          margin: EdgeInsets.only(bottom: 2.w),
          child: ListTile(
            title: Text(ticket.subject),
            subtitle: Text('From: ${ticket.customer}'),
            trailing: _buildPriorityChip(context, ticket.priority),
            onTap: () => _showUpdateStatusDialog(context, ticket),
          ),
        );
      },
    );
  }

  void _showUpdateStatusDialog(BuildContext context, SupportTicket ticket) {
    String newStatus = ticket.status;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Status for ${ticket.id}'),
          content: DropdownButton<String>(
            value: newStatus,
            items: ['Open', 'In Progress', 'Closed'].map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            onChanged: (String? value) {
              if (value != null) {
                setState(() => newStatus = value);
              }
            },
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                await _supportRepository.updateTicketStatus(ticket.id, newStatus);
                if (!mounted) return;
                _fetchTickets();
                Navigator.pop(context);
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPriorityChip(BuildContext context, String priority) {
    Color color;
    switch (priority) {
      case 'High': color = Colors.red; break;
      case 'Medium': color = Colors.orange; break;
      case 'Low': color = Colors.blue; break;
      default: color = Colors.grey; break;
    }
    return Chip(
      label: Text(priority, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
    );
  }
}

import '../models/support_ticket_model.dart';

class SupportRepository {
  // Mock database
  final List<SupportTicket> _tickets = List.generate(10, (index) => SupportTicket(
    id: 'TKT${500 + index}',
    subject: 'Issue with order #123${45 + index}',
    customer: 'Customer ${index + 1}',
    status: ['Open', 'In Progress', 'Closed'][index % 3],
    priority: ['High', 'Medium', 'Low'][index % 3],
  ));

  // Get all support tickets
  Future<List<SupportTicket>> getSupportTickets() async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay
    return _tickets;
  }

  // Update a ticket's status
  Future<void> updateTicketStatus(String ticketId, String newStatus) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _tickets.indexWhere((t) => t.id == ticketId);
    if (index != -1) {
      final ticket = _tickets[index];
      _tickets[index] = SupportTicket(
        id: ticket.id,
        subject: ticket.subject,
        customer: ticket.customer,
        status: newStatus,
        priority: ticket.priority,
      );
    }
  }
}

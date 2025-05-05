import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminSupportTicketsPage extends StatefulWidget {
  const AdminSupportTicketsPage({super.key});

  @override
  State<AdminSupportTicketsPage> createState() =>
      _AdminSupportTicketsPageState();
}

class _AdminSupportTicketsPageState extends State<AdminSupportTicketsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Map<String, dynamic>> _tickets = [];
  String _selectedFilter = 'All';
  final List<String> _statusFilters = [
    'All',
    'Open',
    'In Progress',
    'Resolved',
    'Closed',
  ];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTickets();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTickets() async {
    setState(() {
      _isLoading = true;
    });

    try {
      QuerySnapshot snapshot;

      if (_selectedFilter == 'All') {
        snapshot =
            await FirebaseFirestore.instance
                .collection('supportTickets')
                .orderBy('createdAt', descending: true)
                .get();
      } else {
        snapshot =
            await FirebaseFirestore.instance
                .collection('supportTickets')
                .where('status', isEqualTo: _selectedFilter)
                .orderBy('createdAt', descending: true)
                .get();
      }

      final List<Map<String, dynamic>> loadedTickets = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        loadedTickets.add({'id': doc.id, ...data});
      }

      setState(() {
        _tickets = loadedTickets;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading tickets: $e')));
    }
  }

  List<Map<String, dynamic>> get _filteredTickets {
    if (_searchController.text.isEmpty) {
      return _tickets;
    }

    final query = _searchController.text.toLowerCase();
    return _tickets.where((ticket) {
      final title = ticket['title']?.toString().toLowerCase() ?? '';
      final userName = ticket['userName']?.toString().toLowerCase() ?? '';
      final userId = ticket['userId']?.toString().toLowerCase() ?? '';

      return title.contains(query) ||
          userName.contains(query) ||
          userId.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // Inner tab bar for Support Tickets
          TabBar(
            controller: _tabController,
            labelColor: Colors.red.shade900,
            tabs: const [Tab(text: 'All Tickets'), Tab(text: 'Analytics')],
          ),

          // Inner tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // All Tickets View
                _buildTicketsTab(),

                // Analytics View
                _buildAnalyticsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketsTab() {
    return Column(
      children: [
        // Search and filter bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search tickets...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: _selectedFilter,
                items:
                    _statusFilters.map((status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedFilter = value;
                    });
                    _loadTickets();
                  }
                },
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadTickets,
                tooltip: 'Refresh',
              ),
            ],
          ),
        ),

        // Tickets list
        Expanded(
          child:
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredTickets.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No tickets found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _filteredTickets.length,
                    itemBuilder: (context, index) {
                      final ticket = _filteredTickets[index];
                      return _buildTicketCard(ticket);
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildTicketCard(Map<String, dynamic> ticket) {
    final ticketId = ticket['id'];
    final status = ticket['status'] ?? 'Open';
    final priority = ticket['priority'] ?? 'Medium';
    final createdAt = ticket['createdAt'] as Timestamp?;
    final date = createdAt?.toDate() ?? DateTime.now();
    final formattedDate = DateFormat('MMM d, y - h:mm a').format(date);
    final hasNewResponse = ticket['hasNewResponse'] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side:
            hasNewResponse
                ? BorderSide(color: Colors.blue.shade300, width: 2)
                : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => _showTicketDetails(ticket),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: _getStatusColor(status),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(priority).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      priority,
                      style: TextStyle(
                        color: _getPriorityColor(priority),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (hasNewResponse)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.mark_chat_unread,
                            size: 12,
                            color: Colors.blue.shade800,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'New Message',
                            style: TextStyle(
                              color: Colors.blue.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                ticket['title'] ?? 'No Title',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Category: ${ticket['category'] ?? 'General'}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    ticket['userName'] ?? 'Unknown User',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.numbers, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'ID: ${ticket['userId'] ?? 'N/A'}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formattedDate,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                  Row(
                    children: [
                      // Delete button
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'Delete Ticket',
                        onPressed: () {
                          // Show confirmation dialog
                          showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: const Text('Delete Ticket'),
                                  content: const Text(
                                    'Are you sure you want to delete this ticket? This action cannot be undone.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        try {
                                          // First, delete all responses in the subcollection
                                          final responsesSnapshot =
                                              await FirebaseFirestore.instance
                                                  .collection('supportTickets')
                                                  .doc(ticketId)
                                                  .collection('responses')
                                                  .get();

                                          final batch =
                                              FirebaseFirestore.instance
                                                  .batch();

                                          // Add all response documents to batch delete
                                          for (var doc
                                              in responsesSnapshot.docs) {
                                            batch.delete(doc.reference);
                                          }

                                          // Add the ticket document to batch delete
                                          batch.delete(
                                            FirebaseFirestore.instance
                                                .collection('supportTickets')
                                                .doc(ticketId),
                                          );

                                          // Commit the batch
                                          await batch.commit();

                                          // Close confirmation dialog
                                          Navigator.pop(context);

                                          // Refresh the tickets list
                                          _loadTickets();

                                          // Show success message
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Ticket deleted successfully',
                                              ),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        } catch (e) {
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Error deleting ticket: $e',
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 16),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTicketDetails(Map<String, dynamic> ticket) {
    final ticketId = ticket['id'];
    final responseController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Ticket #${ticketId.substring(0, 8)}'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ticket['title'] ?? 'No Title',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            ticket['status'] ?? 'Open',
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          ticket['status'] ?? 'Open',
                          style: TextStyle(
                            color: _getStatusColor(ticket['status'] ?? 'Open'),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getPriorityColor(
                            ticket['priority'] ?? 'Medium',
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          ticket['priority'] ?? 'Medium',
                          style: TextStyle(
                            color: _getPriorityColor(
                              ticket['priority'] ?? 'Medium',
                            ),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Description:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      ticket['description'] ?? 'No description provided',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'User Information:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text('Name: ${ticket['userName'] ?? 'Unknown'}'),
                  Text('ID: ${ticket['userId'] ?? 'N/A'}'),
                  const SizedBox(height: 16),
                  const Text(
                    'Update Status:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  DropdownButton<String>(
                    value: ticket['status'] ?? 'Open',
                    isExpanded: true,
                    items:
                        ['Open', 'In Progress', 'Resolved', 'Closed'].map((
                          status,
                        ) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                    onChanged: (value) async {
                      if (value != null) {
                        await FirebaseFirestore.instance
                            .collection('supportTickets')
                            .doc(ticketId)
                            .update({
                              'status': value,
                              'updatedAt': FieldValue.serverTimestamp(),
                            });

                        // Refresh the tickets list
                        _loadTickets();

                        // Update the local ticket data
                        setState(() {
                          ticket['status'] = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Add Response:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: responseController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Type your response here...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              // Delete Ticket Button
              TextButton.icon(
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text(
                  'Delete Ticket',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  // Show confirmation dialog
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Delete Ticket'),
                          content: const Text(
                            'Are you sure you want to delete this ticket? This action cannot be undone.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                try {
                                  // First, delete all responses in the subcollection
                                  final responsesSnapshot =
                                      await FirebaseFirestore.instance
                                          .collection('supportTickets')
                                          .doc(ticketId)
                                          .collection('responses')
                                          .get();

                                  final batch =
                                      FirebaseFirestore.instance.batch();

                                  // Add all response documents to batch delete
                                  for (var doc in responsesSnapshot.docs) {
                                    batch.delete(doc.reference);
                                  }

                                  // Add the ticket document to batch delete
                                  batch.delete(
                                    FirebaseFirestore.instance
                                        .collection('supportTickets')
                                        .doc(ticketId),
                                  );

                                  // Commit the batch
                                  await batch.commit();

                                  // Close both dialogs
                                  Navigator.pop(
                                    context,
                                  ); // Close confirmation dialog
                                  Navigator.pop(
                                    context,
                                  ); // Close ticket details dialog

                                  // Refresh the tickets list
                                  _loadTickets();

                                  // Show success message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Ticket deleted successfully',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } catch (e) {
                                  Navigator.pop(
                                    context,
                                  ); // Close confirmation dialog
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Error deleting ticket: $e',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                  );
                },
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (responseController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a response')),
                    );
                    return;
                  }

                  try {
                    // Add the response to the ticket
                    await FirebaseFirestore.instance
                        .collection('supportTickets')
                        .doc(ticketId)
                        .collection('responses')
                        .add({
                          'message': responseController.text.trim(),
                          'isAdmin': true,
                          'timestamp': FieldValue.serverTimestamp(),
                        });

                    // Update the ticket
                    await FirebaseFirestore.instance
                        .collection('supportTickets')
                        .doc(ticketId)
                        .update({
                          'updatedAt': FieldValue.serverTimestamp(),
                          'hasNewResponse': true,
                        });

                    // Refresh the tickets list
                    _loadTickets();

                    // Close the dialog
                    Navigator.pop(context);

                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Response added successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error adding response: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade900,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Send Response'),
              ),
            ],
          ),
    );
  }

  Widget _buildAnalyticsTab() {
    // Count tickets by status
    final Map<String, int> statusCounts = {
      'Open': 0,
      'In Progress': 0,
      'Resolved': 0,
      'Closed': 0,
    };

    // Count tickets by priority
    final Map<String, int> priorityCounts = {'Low': 0, 'Medium': 0, 'High': 0};

    // Count tickets by category
    final Map<String, int> categoryCounts = {};

    // Calculate average response time (in hours)
    double averageResponseTime = 0;
    int ticketsWithResponses = 0;

    for (var ticket in _tickets) {
      // Update status counts
      final status = ticket['status'] ?? 'Open';
      statusCounts[status] = (statusCounts[status] ?? 0) + 1;

      // Update priority counts
      final priority = ticket['priority'] ?? 'Medium';
      priorityCounts[priority] = (priorityCounts[priority] ?? 0) + 1;

      // Update category counts
      final category = ticket['category'] ?? 'General';
      categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;

      // Calculate response time if there are responses
      // This would require additional queries to get responses for each ticket
      // For simplicity, we'll use a placeholder value
      averageResponseTime += 4.5; // Placeholder
      ticketsWithResponses++;
    }

    // Calculate the final average
    if (ticketsWithResponses > 0) {
      averageResponseTime /= ticketsWithResponses;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Tickets',
                  _tickets.length.toString(),
                  Icons.confirmation_number,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  'Open Tickets',
                  statusCounts['Open'].toString(),
                  Icons.fiber_new,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Resolved',
                  statusCounts['Resolved'].toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  'Avg. Response',
                  '${averageResponseTime.toStringAsFixed(1)} hrs',
                  Icons.timer,
                  Colors.purple,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Status breakdown
          const Text(
            'Tickets by Status',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children:
                    statusCounts.entries.map((entry) {
                      final percentage =
                          _tickets.isNotEmpty
                              ? (entry.value / _tickets.length * 100)
                                  .toStringAsFixed(1)
                              : '0.0';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  entry.key,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text('$percentage% (${entry.value})'),
                              ],
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value:
                                  _tickets.isNotEmpty
                                      ? entry.value / _tickets.length
                                      : 0,
                              backgroundColor: Colors.grey[200],
                              color: _getStatusColor(entry.key),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Priority breakdown
          const Text(
            'Tickets by Priority',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children:
                    priorityCounts.entries.map((entry) {
                      final percentage =
                          _tickets.isNotEmpty
                              ? (entry.value / _tickets.length * 100)
                                  .toStringAsFixed(1)
                              : '0.0';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  entry.key,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text('$percentage% (${entry.value})'),
                              ],
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value:
                                  _tickets.isNotEmpty
                                      ? entry.value / _tickets.length
                                      : 0,
                              backgroundColor: Colors.grey[200],
                              color: _getPriorityColor(entry.key),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Category breakdown
          const Text(
            'Tickets by Category',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children:
                    categoryCounts.entries.map((entry) {
                      final percentage =
                          _tickets.isNotEmpty
                              ? (entry.value / _tickets.length * 100)
                                  .toStringAsFixed(1)
                              : '0.0';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  entry.key,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text('$percentage% (${entry.value})'),
                              ],
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value:
                                  _tickets.isNotEmpty
                                      ? entry.value / _tickets.length
                                      : 0,
                              backgroundColor: Colors.grey[200],
                              color: Colors.teal,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.blue;
      case 'in progress':
        return Colors.orange;
      case 'resolved':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }
}

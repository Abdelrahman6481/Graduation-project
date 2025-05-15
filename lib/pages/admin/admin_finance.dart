import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';
import '../../models/firestore_models.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:intl/intl.dart';

class AdminFinancePage extends StatefulWidget {
  const AdminFinancePage({super.key});

  @override
  State<AdminFinancePage> createState() => _AdminFinancePageState();
}

class _AdminFinancePageState extends State<AdminFinancePage> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _payments = [];
  final _firestoreService = FirestoreService();
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredPayments = [];

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPayments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // First load all students to initialize payment records if needed
      final studentsSnapshot =
          await FirebaseFirestore.instance.collection('students').get();

      // Initialize payment records for students if they don't exist
      for (var doc in studentsSnapshot.docs) {
        final studentData = doc.data();
        final studentId = int.tryParse(doc.id) ?? 0;
        final studentName = studentData['name'] ?? 'Unknown';

        if (studentId > 0) {
          // Default amount due is 5000 (this can be customized)
          await _firestoreService.initializeStudentPayment(
            studentId,
            studentName,
            5000.0,
          );
        }
      }

      // Now load all payments
      final paymentsSnapshot =
          await FirebaseFirestore.instance.collection('payments').get();
      final loadedPayments =
          paymentsSnapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'studentId':
                  int.tryParse(data['studentId']?.toString() ?? '0') ?? 0,
              'studentName': data['studentName'] ?? 'Unknown',
              'amountDue': (data['amountDue'] as num?)?.toDouble() ?? 0.0,
              'amountPaid': (data['amountPaid'] as num?)?.toDouble() ?? 0.0,
              'status': data['status'] ?? 'unpaid',
              'lastUpdated':
                  data['lastUpdated'] is Timestamp
                      ? (data['lastUpdated'] as Timestamp).toDate()
                      : DateTime.now(),
            };
          }).toList();

      setState(() {
        _payments = loadedPayments;
        _filteredPayments = loadedPayments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (kDebugMode) {
        debugPrint('Error loading payments: $e');
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading payments: $e')));
    }
  }

  void _filterPayments(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredPayments = _payments;
      } else {
        _filteredPayments =
            _payments.where((payment) {
              final studentName =
                  payment['studentName'].toString().toLowerCase();
              final studentId = payment['studentId'].toString();
              final status = payment['status'].toString().toLowerCase();

              return studentName.contains(query.toLowerCase()) ||
                  studentId.contains(query) ||
                  status.contains(query.toLowerCase());
            }).toList();
      }
    });
  }

  Future<void> _updatePaymentStatus(int studentId, String currentStatus) async {
    try {
      final newStatus = currentStatus == 'paid' ? 'unpaid' : 'paid';
      final amountPaid =
          newStatus == 'paid'
              ? _payments.firstWhere(
                (p) => p['studentId'] == studentId,
                orElse: () => {'amountDue': 0.0},
              )['amountDue']
              : 0.0;

      await _firestoreService.updatePaymentStatus(
        studentId,
        newStatus,
        amountPaid: newStatus == 'paid' ? amountPaid : 0.0,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment status updated to $newStatus')),
      );

      // Refresh the payments list
      await _loadPayments();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating payment status: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Finance Management',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red.shade900,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredPayments.isEmpty
                    ? const Center(child: Text('No payment records found'))
                    : _buildPaymentsTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by name, ID or status...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        onChanged: _filterPayments,
      ),
    );
  }

  Widget _buildPaymentsTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columnSpacing: 20,
          headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
          columns: const [
            DataColumn(
              label: Text(
                'Student ID',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Student Name',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Amount Due',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Amount Paid',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Status',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Last Updated',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Actions',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows:
              _filteredPayments.map((payment) {
                final studentId = payment['studentId'];
                final studentName = payment['studentName'];
                final amountDue = payment['amountDue'];
                final amountPaid = payment['amountPaid'];
                final status = payment['status'];
                final lastUpdated = payment['lastUpdated'];

                return DataRow(
                  cells: [
                    DataCell(Text(studentId.toString())),
                    DataCell(Text(studentName)),
                    DataCell(Text('EGP ${amountDue.toStringAsFixed(2)}')),
                    DataCell(Text('EGP ${amountPaid.toStringAsFixed(2)}')),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              status == 'paid'
                                  ? Colors.green[100]
                                  : Colors.red[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status == 'paid' ? 'Paid' : 'Unpaid',
                          style: TextStyle(
                            color:
                                status == 'paid'
                                    ? Colors.green[800]
                                    : Colors.red[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(DateFormat('MMM dd, yyyy').format(lastUpdated)),
                    ),
                    DataCell(
                      ElevatedButton(
                        onPressed:
                            () => _updatePaymentStatus(studentId, status),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              status == 'paid'
                                  ? Colors.red[400]
                                  : Colors.green[600],
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                        ),
                        child: Text(
                          status == 'paid' ? 'Mark Unpaid' : 'Mark Paid',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
        ),
      ),
    );
  }
}

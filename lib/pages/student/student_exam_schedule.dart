import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentExamSchedulePage extends StatefulWidget {
  const StudentExamSchedulePage({super.key});

  @override
  State<StudentExamSchedulePage> createState() =>
      _StudentExamSchedulePageState();
}

class _StudentExamSchedulePageState extends State<StudentExamSchedulePage> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _examSchedules = [];

  @override
  void initState() {
    super.initState();
    _loadExamSchedules();
  }

  Future<void> _loadExamSchedules() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collection('examSchedules')
              .orderBy('date')
              .get();
      final List<Map<String, dynamic>> loadedSchedules = [];
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        loadedSchedules.add({'id': doc.id, ...data});
      }
      setState(() {
        _examSchedules = loadedSchedules;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading exam schedules: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Schedule'),
        backgroundColor: Colors.red.shade900,
        foregroundColor: Colors.white,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _examSchedules.isEmpty
              ? const Center(child: Text('No exam schedules found'))
              : RefreshIndicator(
                onRefresh: _loadExamSchedules,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _examSchedules.length,
                  itemBuilder: (context, index) {
                    final schedule = _examSchedules[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          schedule['courseName'] ?? 'Unknown Course',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 16),
                                const SizedBox(width: 8),
                                Text('Date: ${schedule['date']}'),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 16),
                                const SizedBox(width: 8),
                                Text('Time: ${schedule['time']}'),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 16),
                                const SizedBox(width: 8),
                                Text('Location: ${schedule['location']}'),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.timer, size: 16),
                                const SizedBox(width: 8),
                                Text('Duration: ${schedule['duration']}'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
    );
  }
}

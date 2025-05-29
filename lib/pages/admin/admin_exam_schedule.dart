import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminExamSchedulePage extends StatefulWidget {
  const AdminExamSchedulePage({super.key});

  @override
  State<AdminExamSchedulePage> createState() => _AdminExamSchedulePageState();
}

class _AdminExamSchedulePageState extends State<AdminExamSchedulePage> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _courses = [];
  List<Map<String, dynamic>> _examSchedules = [];

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  String _selectedCourseId = '';
  final _examDateController = TextEditingController();
  final _examTimeController = TextEditingController();
  final _examLocationController = TextEditingController();
  final _examDurationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCourses();
    _loadExamSchedules();
  }

  @override
  void dispose() {
    _examDateController.dispose();
    _examTimeController.dispose();
    _examLocationController.dispose();
    _examDurationController.dispose();
    super.dispose();
  }

  Future<void> _loadCourses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collection('courses')
              .where('isActive', isEqualTo: true)
              .get();

      final List<Map<String, dynamic>> loadedCourses = [];
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        loadedCourses.add({'id': doc.id, ...data});
      }

      setState(() {
        _courses = loadedCourses;
        if (_courses.isNotEmpty) {
          _selectedCourseId = _courses[0]['id'];
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading courses: $e')));
      }
    }
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

  Future<void> _addExamSchedule() async {
    print('DEBUG: Trying to add exam schedule...');
    if (!_formKey.currentState!.validate()) {
      print('DEBUG: Form not valid');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields correctly!')),
        );
      }
      return;
    }

    if (_courses.isEmpty) {
      print('DEBUG: No courses available');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No courses available to add exam schedule!'),
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print(
        'DEBUG: _selectedCourseId=$_selectedCourseId, _courses=${_courses.map((c) => c['id']).toList()}',
      );
      final selectedCourse = _courses.firstWhere(
        (course) => course['id'].toString() == _selectedCourseId,
        orElse: () {
          print('DEBUG: No matching course found!');
          return <String, dynamic>{};
        },
      );
      if (selectedCourse.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Selected course not found!')),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }
      print('DEBUG: selectedCourse=$selectedCourse');

      await FirebaseFirestore.instance.collection('examSchedules').add({
        'courseId': _selectedCourseId,
        'courseName': selectedCourse['name'],
        'date': _examDateController.text,
        'time': _examTimeController.text,
        'location': _examLocationController.text,
        'duration': _examDurationController.text,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('DEBUG: Exam schedule added successfully!');

      // Clear form
      _examDateController.clear();
      _examTimeController.clear();
      _examLocationController.clear();
      _examDurationController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exam schedule added successfully!')),
        );
      }

      // Refresh the list
      await _loadExamSchedules();
    } catch (e) {
      print('DEBUG: Error adding exam schedule: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding exam schedule: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteExamSchedule(String scheduleId) async {
    try {
      await FirebaseFirestore.instance
          .collection('examSchedules')
          .doc(scheduleId)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exam schedule deleted successfully!')),
        );
      }

      // Refresh the list
      await _loadExamSchedules();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting exam schedule: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            labelColor: Colors.red.shade900,
            tabs: const [
              Tab(text: 'View Schedules'),
              Tab(text: 'Add Schedule'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // View Schedules Tab
                _buildSchedulesList(),

                // Add Schedule Tab
                _buildAddScheduleForm(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchedulesList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_examSchedules.isEmpty) {
      return const Center(child: Text('No exam schedules found'));
    }

    return RefreshIndicator(
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
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteExamSchedule(schedule['id']),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddScheduleForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add New Exam Schedule',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Course Dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Select Course',
                border: OutlineInputBorder(),
              ),
              value:
                  _selectedCourseId.isEmpty && _courses.isNotEmpty
                      ? _courses[0]['id'].toString()
                      : _selectedCourseId,
              items:
                  _courses.map((course) {
                    return DropdownMenuItem<String>(
                      value: course['id'].toString(),
                      child: Text(course['name'] ?? 'Unknown Course'),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCourseId = value!;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a course';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Date Field
            TextFormField(
              controller: _examDateController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Exam Date (YYYY-MM-DD)',
                border: OutlineInputBorder(),
              ),
              onTap: () async {
                FocusScope.of(context).requestFocus(FocusNode());
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  _examDateController.text = DateFormat(
                    'yyyy-MM-dd',
                  ).format(picked);
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter exam date';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Time Field
            TextFormField(
              controller: _examTimeController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Exam Time (HH:MM)',
                border: OutlineInputBorder(),
              ),
              onTap: () async {
                FocusScope.of(context).requestFocus(FocusNode());
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (picked != null) {
                  _examTimeController.text = picked.format(context);
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter exam time';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Location Field
            TextFormField(
              controller: _examLocationController,
              decoration: const InputDecoration(
                labelText: 'Exam Location',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter exam location';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Duration Field
            TextFormField(
              controller: _examDurationController,
              decoration: const InputDecoration(
                labelText: 'Exam Duration (e.g., 2 hours)',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter exam duration';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _addExamSchedule,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade900,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          'Add Exam Schedule',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

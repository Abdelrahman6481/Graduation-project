import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class CourseRegistration extends StatefulWidget {
  final String? studentId;

  const CourseRegistration({super.key, this.studentId});

  @override
  State<CourseRegistration> createState() => _CourseRegistrationState();
}

class _CourseRegistrationState extends State<CourseRegistration> {
  final List<Map<String, dynamic>> _selectedCourses = [];
  bool _isLoading = true;
  List<Map<String, dynamic>> _availableCourses = [];

  // Colors for course cards
  final List<Map<String, Color>> _courseColors = [
    {'bg': Colors.blue.shade100, 'text': Colors.blue.shade900},
    {'bg': Colors.green.shade100, 'text': Colors.green.shade900},
    {'bg': Colors.purple.shade100, 'text': Colors.purple.shade900},
    {'bg': Colors.orange.shade100, 'text': Colors.orange.shade900},
    {'bg': Colors.teal.shade100, 'text': Colors.teal.shade900},
    {'bg': Colors.pink.shade100, 'text': Colors.pink.shade900},
    {'bg': Colors.indigo.shade100, 'text': Colors.indigo.shade900},
    {'bg': Colors.red.shade100, 'text': Colors.red.shade900},
    {'bg': Colors.amber.shade100, 'text': Colors.amber.shade900},
    {'bg': Colors.deepPurple.shade100, 'text': Colors.deepPurple.shade900},
  ];

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('courses').get();

      final List<Map<String, dynamic>> loadedCourses = [];

      int colorIndex = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final course = {
          ...data,
          'id': doc.id,
          'color': _courseColors[colorIndex % _courseColors.length]['bg'],
          'textColor': _courseColors[colorIndex % _courseColors.length]['text'],
        };

        // Get lectures directly from the course document
        if (data['lectures'] != null && (data['lectures'] as List).isNotEmpty) {
          // Extract lectures from the course document
          final List<dynamic> lectureDocs = data['lectures'] as List;

          // Organize lectures into sections
          // We'll use one section "A" for simplicity, but you could split them based on some criteria
          final String sectionId = 'A';
          final List<Map<String, dynamic>> availableSlots = [];

          // Create a section with all lectures
          final Map<String, dynamic> section = {
            'id': sectionId,
            'lectures':
                lectureDocs
                    .map(
                      (lecture) => {
                        'day': lecture['day'] ?? 'Unknown',
                        'time': lecture['time'] ?? 'Unknown',
                        'room': lecture['room'] ?? 'Unknown',
                      },
                    )
                    .toList(),
          };

          availableSlots.add(section);
          course['availableSlots'] = availableSlots;
        } else {
          // No lectures found in the course document, create an empty list
          course['availableSlots'] = [];
        }

        loadedCourses.add(course);
        colorIndex++;
      }

      setState(() {
        _availableCourses = loadedCourses;
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading courses: $e');
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.red.shade900,
        title: const Text('Course Registration'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () => _showSelectedCourses(),
              ),
              if (_selectedCourses.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${_selectedCourses.length}',
                      style: TextStyle(
                        color: Colors.red.shade900,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _loadCourses,
                child:
                    _availableCourses.isEmpty
                        ? Center(child: Text('No courses available'))
                        : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _availableCourses.length,
                          itemBuilder:
                              (context, index) =>
                                  _buildCourseCard(_availableCourses[index]),
                        ),
              ),
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showTimeSlots(course),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course['code'] ?? 'No Code',
                      style: TextStyle(
                        color: course['textColor'],
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      course['name'] ?? 'Unnamed Course',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course['instructor'] ?? 'No Instructor Assigned',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: course['color'],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${course['credits'] ?? 0} Credits',
                  style: TextStyle(
                    color: course['textColor'],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTimeSlots(Map<String, dynamic> course) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${course['code']} - ${course['name']}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Available Time Slots:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (course['availableSlots'] == null ||
                    course['availableSlots'].isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: Text(
                        'No lecture schedules available for this course',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )
                else
                  ...course['availableSlots']
                      .map<Widget>(
                        (slot) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            onTap: () {
                              _selectTimeSlot(course, slot);
                              Navigator.pop(context);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Section ${slot['id']}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...slot['lectures']
                                      .map<Widget>(
                                        (lecture) => Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 4,
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.access_time,
                                                size: 16,
                                                color: course['textColor'],
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                '${lecture['day']}: ${lecture['time']} (Room ${lecture['room']})',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
              ],
            ),
          ),
    );
  }

  void _selectTimeSlot(Map<String, dynamic> course, Map<String, dynamic> slot) {
    setState(() {
      // Remove any existing selection of this course
      _selectedCourses.removeWhere(
        (selected) => selected['code'] == course['code'],
      );

      // Add the course with selected time slot
      final selectedCourse = Map<String, dynamic>.from(course);
      selectedCourse['selectedSlot'] = slot;
      _selectedCourses.add(selectedCourse);
    });
  }

  void _showSelectedCourses() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Selected Courses (${_selectedCourses.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_selectedCourses.isEmpty)
                  const Center(
                    child: Text(
                      'No courses selected',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: _selectedCourses.length,
                      itemBuilder: (context, index) {
                        final course = _selectedCourses[index];
                        final slot = course['selectedSlot'];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(
                              '${course['code']} - ${course['name']}',
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Section ${slot['id']}'),
                                ...slot['lectures']
                                    .map<Widget>(
                                      (lecture) => Text(
                                        '${lecture['day']}: ${lecture['time']}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    )
                                    .toList(),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                setState(() {
                                  _selectedCourses.remove(course);
                                });
                                Navigator.pop(context);
                                _showSelectedCourses();
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 16),
                if (_selectedCourses.isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _registerCourses();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade900,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Register Selected Courses'),
                    ),
                  ),
              ],
            ),
          ),
    );
  }

  Future<void> _registerCourses() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(color: Colors.red.shade900),
              const SizedBox(width: 16),
              const Text("Registering courses..."),
            ],
          ),
        );
      },
    );

    try {
      // Validate student ID
      final studentId = widget.studentId;
      if (studentId == null || studentId.isEmpty) {
        throw Exception("Student ID is not available");
      }

      // For each selected course, create a registration record
      for (var course in _selectedCourses) {
        final courseId = course['id'];

        // Check if the student is already registered for this course
        final existingRegistration =
            await FirebaseFirestore.instance
                .collection('courseRegistrations')
                .where(
                  'studentId',
                  isEqualTo: int.tryParse(studentId) ?? studentId,
                )
                .where('courseId', isEqualTo: courseId)
                .where('status', isEqualTo: 'active')
                .get();

        if (existingRegistration.docs.isEmpty) {
          // Create new registration document
          await FirebaseFirestore.instance
              .collection('courseRegistrations')
              .add({
                'studentId': int.tryParse(studentId) ?? studentId,
                'courseId': courseId,
                'registrationDate': FieldValue.serverTimestamp(),
                'status': 'active',
                'sectionId': course['selectedSlot']['id'],
              });
        }
      }

      if (mounted) {
        // Close loading dialog
        Navigator.of(context).pop();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Courses registered successfully! They will now appear in your schedule.',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }

      // Clear selected courses
      setState(() {
        _selectedCourses.clear();
      });
    } catch (e) {
      if (mounted) {
        // Close loading dialog
        Navigator.of(context).pop();

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to register courses: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      if (kDebugMode) {
        debugPrint('Error registering courses: $e');
      }
    }
  }
}

import 'package:flutter/material.dart';

class CourseRegistration extends StatefulWidget {
  const CourseRegistration({super.key});

  @override
  State<CourseRegistration> createState() => _CourseRegistrationState();
}

class _CourseRegistrationState extends State<CourseRegistration> {
  final List<Map<String, dynamic>> _availableCourses = [
    {
      'code': 'CS301',
      'name': 'Software Engineering',
      'credits': 3,
      'instructor': 'Dr. Ahmed Hassan',
      'availableSlots': [
        {
          'id': '1A',
          'lectures': [
            {'day': 'Sunday', 'time': '08:00 AM - 10:00 AM', 'room': '301'},
            {'day': 'Tuesday', 'time': '10:00 AM - 12:00 PM', 'room': '302'},
          ],
        },
        {
          'id': '1B',
          'lectures': [
            {'day': 'Monday', 'time': '10:00 AM - 12:00 PM', 'room': '303'},
            {'day': 'Wednesday', 'time': '08:00 AM - 10:00 AM', 'room': '304'},
          ],
        },
      ],
      'color': Colors.blue.shade100,
      'textColor': Colors.blue.shade900,
    },
    {
      'code': 'CS302',
      'name': 'Database Systems',
      'credits': 3,
      'instructor': 'Dr. Sarah Wilson',
      'availableSlots': [
        {
          'id': '2A',
          'lectures': [
            {'day': 'Monday', 'time': '01:00 PM - 03:00 PM', 'room': '201'},
            {'day': 'Wednesday', 'time': '02:00 PM - 04:00 PM', 'room': '202'},
          ],
        },
        {
          'id': '2B',
          'lectures': [
            {'day': 'Sunday', 'time': '02:00 PM - 04:00 PM', 'room': '203'},
            {'day': 'Tuesday', 'time': '01:00 PM - 03:00 PM', 'room': '204'},
          ],
        },
      ],
      'color': Colors.green.shade100,
      'textColor': Colors.green.shade900,
    },
    {
      'code': 'CS303',
      'name': 'Computer Networks',
      'credits': 3,
      'instructor': 'Dr. Michael Brown',
      'availableSlots': [
        {
          'id': '3A',
          'lectures': [
            {'day': 'Sunday', 'time': '11:00 AM - 01:00 PM', 'room': '401'},
            {'day': 'Tuesday', 'time': '02:00 PM - 04:00 PM', 'room': '402'},
          ],
        },
      ],
      'color': Colors.purple.shade100,
      'textColor': Colors.purple.shade900,
    },
    {
      'code': 'CS304',
      'name': 'Artificial Intelligence',
      'credits': 3,
      'instructor': 'Dr. Emily Parker',
      'availableSlots': [
        {
          'id': '4A',
          'lectures': [
            {'day': 'Monday', 'time': '08:00 AM - 10:00 AM', 'room': '301'},
            {'day': 'Wednesday', 'time': '10:00 AM - 12:00 PM', 'room': '302'},
          ],
        },
      ],
      'color': Colors.orange.shade100,
      'textColor': Colors.orange.shade900,
    },
    {
      'code': 'CS305',
      'name': 'Web Development',
      'credits': 3,
      'instructor': 'Dr. John Smith',
      'availableSlots': [
        {
          'id': '5A',
          'lectures': [
            {'day': 'Sunday', 'time': '09:00 AM - 11:00 AM', 'room': '501'},
            {'day': 'Tuesday', 'time': '09:00 AM - 11:00 AM', 'room': '502'},
          ],
        },
        {
          'id': '5B',
          'lectures': [
            {'day': 'Monday', 'time': '02:00 PM - 04:00 PM', 'room': '503'},
            {'day': 'Wednesday', 'time': '02:00 PM - 04:00 PM', 'room': '504'},
          ],
        },
      ],
      'color': Colors.teal.shade100,
      'textColor': Colors.teal.shade900,
    },
    {
      'code': 'CS306',
      'name': 'Mobile App Development',
      'credits': 3,
      'instructor': 'Dr. Lisa Anderson',
      'availableSlots': [
        {
          'id': '6A',
          'lectures': [
            {'day': 'Monday', 'time': '11:00 AM - 01:00 PM', 'room': '601'},
            {'day': 'Wednesday', 'time': '11:00 AM - 01:00 PM', 'room': '602'},
          ],
        },
      ],
      'color': Colors.pink.shade100,
      'textColor': Colors.pink.shade900,
    },
    {
      'code': 'CS307',
      'name': 'Data Science',
      'credits': 3,
      'instructor': 'Dr. Robert Johnson',
      'availableSlots': [
        {
          'id': '7A',
          'lectures': [
            {'day': 'Sunday', 'time': '01:00 PM - 03:00 PM', 'room': '701'},
            {'day': 'Tuesday', 'time': '01:00 PM - 03:00 PM', 'room': '702'},
          ],
        },
      ],
      'color': Colors.indigo.shade100,
      'textColor': Colors.indigo.shade900,
    },
    {
      'code': 'CS308',
      'name': 'Cybersecurity',
      'credits': 3,
      'instructor': 'Dr. David Miller',
      'availableSlots': [
        {
          'id': '8A',
          'lectures': [
            {'day': 'Monday', 'time': '09:00 AM - 11:00 AM', 'room': '801'},
            {'day': 'Wednesday', 'time': '09:00 AM - 11:00 AM', 'room': '802'},
          ],
        },
      ],
      'color': Colors.red.shade100,
      'textColor': Colors.red.shade900,
    },
    {
      'code': 'CS309',
      'name': 'Cloud Computing',
      'credits': 3,
      'instructor': 'Dr. Karen White',
      'availableSlots': [
        {
          'id': '9A',
          'lectures': [
            {'day': 'Sunday', 'time': '10:00 AM - 12:00 PM', 'room': '901'},
            {'day': 'Tuesday', 'time': '10:00 AM - 12:00 PM', 'room': '902'},
          ],
        },
      ],
      'color': Colors.amber.shade100,
      'textColor': Colors.amber.shade900,
    },
    {
      'code': 'CS310',
      'name': 'Machine Learning',
      'credits': 3,
      'instructor': 'Dr. Thomas Lee',
      'availableSlots': [
        {
          'id': '10A',
          'lectures': [
            {'day': 'Monday', 'time': '01:00 PM - 03:00 PM', 'room': '1001'},
            {'day': 'Wednesday', 'time': '01:00 PM - 03:00 PM', 'room': '1002'},
          ],
        },
      ],
      'color': Colors.deepPurple.shade100,
      'textColor': Colors.deepPurple.shade900,
    },
  ];

  final List<Map<String, dynamic>> _selectedCourses = [];

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
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _availableCourses.length,
        itemBuilder:
            (context, index) => _buildCourseCard(_availableCourses[index]),
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
                      course['code'],
                      style: TextStyle(
                        color: course['textColor'],
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      course['name'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course['instructor'],
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
                  '${course['credits']} Credits',
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Courses registered successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        setState(() {
                          _selectedCourses.clear();
                        });
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
}

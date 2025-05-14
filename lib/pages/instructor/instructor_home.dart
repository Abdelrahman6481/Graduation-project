import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';
import 'grade_entry_form.dart';
import 'package:flutter/foundation.dart';

class InstructorHomePage extends StatefulWidget {
  final Map<String, dynamic> instructor;

  const InstructorHomePage({super.key, required this.instructor});

  @override
  State<InstructorHomePage> createState() => _InstructorHomePageState();
}

class _InstructorHomePageState extends State<InstructorHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Map<String, dynamic>> _assignedCourses = [];
  Map<String, List<Map<String, dynamic>>> _scheduleByday = {};
  final List<String> _weekDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadAssignedCourses();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAssignedCourses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get assigned course IDs from instructor data
      List<String> assignedCourseIds = [];
      if (widget.instructor['assignedCourses'] != null) {
        assignedCourseIds = List<String>.from(
          widget.instructor['assignedCourses'],
        );
      }

      if (assignedCourseIds.isEmpty) {
        setState(() {
          _isLoading = false;
          _assignedCourses = [];
        });
        return;
      }

      // Fetch course details for each assigned course
      final List<Map<String, dynamic>> courses = [];
      for (String courseId in assignedCourseIds) {
        final doc =
            await FirebaseFirestore.instance
                .collection('courses')
                .doc(courseId)
                .get();

        if (doc.exists) {
          final courseData = doc.data() as Map<String, dynamic>;
          courses.add({'id': doc.id, ...courseData});
        }
      }

      // Organize schedule by day
      Map<String, List<Map<String, dynamic>>> scheduleByDay = {};
      for (var course in courses) {
        if (course['lectures'] != null) {
          final lectures = List<Map<String, dynamic>>.from(course['lectures']);

          for (var lecture in lectures) {
            final day = lecture['day'] as String;
            if (!scheduleByDay.containsKey(day)) {
              scheduleByDay[day] = [];
            }

            scheduleByDay[day]!.add({
              'courseId': course['id'],
              'courseName': course['name'],
              'courseCode': course['code'],
              'time': lecture['time'],
              'room': lecture['room'],
            });
          }
        }
      }

      setState(() {
        _assignedCourses = courses;
        _scheduleByday = scheduleByDay;
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading assigned courses: $e');
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
      appBar: AppBar(
        title: const Text('Instructor Dashboard'),
        backgroundColor: Colors.red.shade900,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/prelogin');
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Courses', icon: Icon(Icons.book)),
            Tab(text: 'Schedule', icon: Icon(Icons.schedule)),
            Tab(text: 'Attendance', icon: Icon(Icons.how_to_reg)),
            Tab(text: 'Results', icon: Icon(Icons.grading)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Overview Tab
          _buildOverviewTab(),

          // Courses Tab
          _buildCoursesTab(),

          // Schedule Tab
          _buildScheduleTab(),

          // Attendance Tab
          _buildAttendanceTab(),

          // Results Tab
          _buildResultsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Instructor info card
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.red.shade900,
                        foregroundColor: Colors.white,
                        radius: 30,
                        child: Text(
                          widget.instructor['name']
                                  ?.substring(0, 1)
                                  .toUpperCase() ??
                              'I',
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.instructor['name'] ?? 'Unknown',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.instructor['academicDegree'] ??
                                  'Instructor',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  _infoRow(
                    Icons.email,
                    'Email',
                    widget.instructor['email'] ?? 'N/A',
                  ),
                  _infoRow(
                    Icons.phone,
                    'Phone',
                    widget.instructor['phone'] ?? 'N/A',
                  ),
                  _infoRow(
                    Icons.location_on,
                    'Address',
                    widget.instructor['address'] ?? 'N/A',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Stats section
          Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade900,
            ),
          ),
          const SizedBox(height: 16),

          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Row(
                children: [
                  Expanded(
                    child: _statsCard(
                      'Assigned Courses',
                      _assignedCourses.length.toString(),
                      Icons.book,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _statsCard(
                      'Weekly Lectures',
                      _calculateTotalLectures().toString(),
                      Icons.schedule,
                      Colors.orange,
                    ),
                  ),
                ],
              ),

          const SizedBox(height: 24),

          // Today's schedule summary
          Text(
            'Today\'s Schedule',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade900,
            ),
          ),
          const SizedBox(height: 16),

          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildTodaySchedule(),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.red.shade900, size: 20),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _statsCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateTotalLectures() {
    int total = 0;
    for (var day in _scheduleByday.keys) {
      total += _scheduleByday[day]?.length ?? 0;
    }
    return total;
  }

  Widget _buildTodaySchedule() {
    // Get today's day name
    final today = DateTime.now();
    final dayName =
        _weekDays[today.weekday -
            1]; // 0 is Monday in _weekDays, but 1 in DateTime.weekday

    final todaySchedule = _scheduleByday[dayName] ?? [];

    if (todaySchedule.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'No lectures scheduled for today',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
        ),
      );
    }

    // Sort by time
    todaySchedule.sort(
      (a, b) => a['time'].toString().compareTo(b['time'].toString()),
    );

    return Column(
      children:
          todaySchedule.map((lecture) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    lecture['courseCode'].substring(0, 2),
                    style: TextStyle(color: Colors.blue.shade900),
                  ),
                ),
                title: Text(lecture['courseName']),
                subtitle: Text('${lecture['time']} - Room ${lecture['room']}'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Navigate to course details
                  _tabController.animateTo(1); // Go to Courses tab
                },
              ),
            );
          }).toList(),
    );
  }

  Widget _buildCoursesTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_assignedCourses.isEmpty) {
      return const Center(child: Text('No courses assigned to you yet'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _assignedCourses.length,
      itemBuilder: (context, index) {
        final course = _assignedCourses[index];
        final lectures =
            course['lectures'] != null
                ? List<Map<String, dynamic>>.from(course['lectures'])
                : <Map<String, dynamic>>[];

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: Colors.red.shade900,
              foregroundColor: Colors.white,
              child: Text(course['code']?.substring(0, 2) ?? 'C'),
            ),
            title: Text(course['name'] ?? 'Unknown Course'),
            subtitle: Text('${course['code']} • ${course['credits']} Credits'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(course['description'] ?? 'No description available'),

                    const SizedBox(height: 16),
                    Text(
                      'Schedule:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade900,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Display lecture schedule
                    if (lectures.isEmpty)
                      const Text(
                        'No lectures scheduled',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      )
                    else
                      Column(
                        children:
                            lectures.map((lecture) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: Colors.blue.shade800,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${lecture['day']} • ${lecture['time']} • Room ${lecture['room']}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScheduleTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_scheduleByday.isEmpty) {
      return const Center(child: Text('No lectures scheduled yet'));
    }

    return DefaultTabController(
      length: 7,
      child: Column(
        children: [
          Container(
            color: Colors.grey[200],
            child: TabBar(
              isScrollable: true,
              labelColor: Colors.red.shade900,
              unselectedLabelColor: Colors.grey[700],
              tabs: _weekDays.map((day) => Tab(text: day)).toList(),
            ),
          ),
          Expanded(
            child: TabBarView(
              children:
                  _weekDays.map((day) {
                    final daySchedule = _scheduleByday[day] ?? [];

                    if (daySchedule.isEmpty) {
                      return const Center(
                        child: Text('No lectures scheduled for this day'),
                      );
                    }

                    // Sort by time
                    daySchedule.sort(
                      (a, b) =>
                          a['time'].toString().compareTo(b['time'].toString()),
                    );

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: daySchedule.length,
                      itemBuilder: (context, index) {
                        final lecture = daySchedule[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.access_time, size: 20),
                                Text(
                                  lecture['time'].split('-')[0].trim(),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            title: Text(lecture['courseName']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(lecture['courseCode']),
                                Text('Room: ${lecture['room']}'),
                              ],
                            ),
                            isThreeLine: true,
                          ),
                        );
                      },
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_assignedCourses.isEmpty) {
      return const Center(
        child: Text('No courses assigned to take attendance'),
      );
    }

    return DefaultTabController(
      length: _assignedCourses.length,
      child: Column(
        children: [
          Container(
            color: Colors.grey[200],
            child: TabBar(
              isScrollable: true,
              labelColor: Colors.red.shade900,
              unselectedLabelColor: Colors.grey,
              tabs:
                  _assignedCourses
                      .map((course) => Tab(text: course['code']))
                      .toList(),
            ),
          ),
          Expanded(
            child: TabBarView(
              children:
                  _assignedCourses
                      .map((course) => _buildCourseAttendanceTab(course))
                      .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_assignedCourses.isEmpty) {
      return const Center(child: Text('No courses assigned to manage results'));
    }

    return DefaultTabController(
      length: _assignedCourses.length,
      child: Column(
        children: [
          Container(
            color: Colors.grey[200],
            child: TabBar(
              isScrollable: true,
              labelColor: Colors.red.shade900,
              unselectedLabelColor: Colors.grey,
              tabs:
                  _assignedCourses
                      .map((course) => Tab(text: course['code']))
                      .toList(),
            ),
          ),
          Expanded(
            child: TabBarView(
              children:
                  _assignedCourses
                      .map((course) => _buildCourseResultsTab(course))
                      .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseResultsTab(Map<String, dynamic> course) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course info header
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course['name'] ?? 'Unknown Course',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Code: ${course['code']} • Credits: ${course['credits']}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Grade entry button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade900,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Enter Student Grades'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => GradeEntryForm(
                          course: course,
                          instructor: widget.instructor,
                        ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // Results list
          const Text(
            'Recent Results',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: FirestoreService().getAllCourseResults(
                int.tryParse(course['id'].toString()) ?? 0,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final results = snapshot.data ?? [];

                if (results.isEmpty) {
                  return const Center(
                    child: Text('No results recorded for this course yet'),
                  );
                }

                return ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final result = results[index];
                    final studentName =
                        result['studentName'] ?? 'Unknown Student';
                    final studentId = result['studentId'] ?? 'N/A';
                    final totalGrade = result['totalGrade'] ?? 0.0;
                    final letterGrade = result['letterGrade'] ?? 'N/A';
                    final isPublished = result['isPublished'] ?? false;

                    Color gradeColor;
                    switch (letterGrade) {
                      case 'A':
                        gradeColor = Colors.green;
                        break;
                      case 'B':
                        gradeColor = Colors.blue;
                        break;
                      case 'C':
                        gradeColor = Colors.orange;
                        break;
                      case 'D':
                        gradeColor = Colors.deepOrange;
                        break;
                      default:
                        gradeColor = Colors.red;
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: gradeColor.withAlpha(51),
                          child: Text(
                            letterGrade,
                            style: TextStyle(
                              color: gradeColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(studentName),
                        subtitle: Text('ID: $studentId'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${totalGrade.toStringAsFixed(1)}/100',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isPublished
                                        ? Colors.green.withAlpha(51)
                                        : Colors.grey.withAlpha(51),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isPublished ? 'Published' : 'Draft',
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      isPublished ? Colors.green : Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          // Navigate to edit this student's grade
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => GradeEntryForm(
                                    course: course,
                                    instructor: widget.instructor,
                                  ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseAttendanceTab(Map<String, dynamic> course) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: FirestoreService().getStudentsInCourse(
        int.tryParse(course['id'].toString()) ?? 0,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final students = snapshot.data ?? [];
        if (students.isEmpty) {
          return const Center(
            child: Text('No students enrolled in this course'),
          );
        }

        return FutureBuilder<List<Map<String, dynamic>>>(
          future: FirestoreService().getAttendanceForCourse(
            int.tryParse(course['id'].toString()) ?? 0,
          ),
          builder: (context, attendanceSnapshot) {
            final attendanceData = attendanceSnapshot.data ?? [];

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 4,
                    color: Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.people,
                                color: Colors.red.shade900,
                                size: 32,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Attendance for ${course['name']}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _buildAttendanceStatCard(
                                "Students Enrolled",
                                students.length.toString(),
                                Icons.school,
                                Colors.blue,
                              ),
                              const SizedBox(width: 16),
                              _buildAttendanceStatCard(
                                "Attendance Sessions",
                                _countAttendanceSessions(
                                  attendanceData,
                                ).toString(),
                                Icons.date_range,
                                Colors.green,
                              ),
                              const SizedBox(width: 16),
                              _buildAttendanceStatCard(
                                "Average Attendance",
                                "${_calculateAverageAttendance(attendanceData, students.length)}%",
                                Icons.trending_up,
                                Colors.orange,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Attendance Data',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade900,
                        ),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add_circle),
                        label: const Text('Take Attendance'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade900,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          elevation: 3,
                        ),
                        onPressed:
                            () => _showTakeAttendanceDialog(course, students),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Attendance visualization
                  if (attendanceData.isNotEmpty)
                    Card(
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Attendance Overview',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 120,
                              child: _buildAttendanceChart(
                                attendanceData,
                                students.length,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  Expanded(child: _buildAttendanceHistoryList(course)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAttendanceStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _countAttendanceSessions(List<Map<String, dynamic>> attendanceData) {
    // Group by date to count unique sessions
    final sessions = <String>{};

    for (var record in attendanceData) {
      final date = (record['date'] as Timestamp).toDate();
      final dateStr = '${date.year}-${date.month}-${date.day}';
      sessions.add(dateStr);
    }

    return sessions.length;
  }

  double _calculateAverageAttendance(
    List<Map<String, dynamic>> attendanceData,
    int totalStudents,
  ) {
    if (attendanceData.isEmpty || totalStudents == 0) return 0.0;

    // Group by date
    Map<String, List<Map<String, dynamic>>> byDate = {};

    for (var record in attendanceData) {
      final date = (record['date'] as Timestamp).toDate();
      final dateStr = '${date.year}-${date.month}-${date.day}';

      if (!byDate.containsKey(dateStr)) {
        byDate[dateStr] = [];
      }
      byDate[dateStr]!.add(record);
    }

    // Calculate average attendance rate across all sessions
    double totalRate = 0.0;

    for (var session in byDate.values) {
      int present = session.where((r) => r['isPresent'] == true).length;
      double rate = present / totalStudents * 100;
      totalRate += rate;
    }

    return byDate.isEmpty
        ? 0.0
        : double.parse((totalRate / byDate.length).toStringAsFixed(1));
  }

  Widget _buildAttendanceChart(
    List<Map<String, dynamic>> attendanceData,
    int totalStudents,
  ) {
    // Group by date
    Map<String, List<Map<String, dynamic>>> byDate = {};

    for (var record in attendanceData) {
      final date = (record['date'] as Timestamp).toDate();
      final dateStr = '${date.month}/${date.day}';

      if (!byDate.containsKey(dateStr)) {
        byDate[dateStr] = [];
      }
      byDate[dateStr]!.add(record);
    }

    // Sort dates chronologically
    final dates =
        byDate.keys.toList()..sort((a, b) {
          final partsA = a.split('/').map(int.parse).toList();
          final partsB = b.split('/').map(int.parse).toList();

          if (partsA[0] != partsB[0]) return partsA[0] - partsB[0];
          return partsA[1] - partsB[1];
        });

    // Take only the most recent 10 dates
    final recentDates =
        dates.length > 10 ? dates.sublist(dates.length - 10) : dates;

    return Row(
      children: [
        // Y-axis label
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('100%', style: TextStyle(fontSize: 10)),
              const Text('50%', style: TextStyle(fontSize: 10)),
              const Text('0%', style: TextStyle(fontSize: 10)),
            ],
          ),
        ),

        // Chart content
        Expanded(
          child: Column(
            children: [
              // Chart bars
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children:
                      recentDates.map((dateStr) {
                        final records = byDate[dateStr]!;
                        final presentCount =
                            records.where((r) => r['isPresent'] == true).length;
                        final attendanceRate =
                            totalStudents > 0
                                ? presentCount / totalStudents
                                : 0.0;

                        return Tooltip(
                          message:
                              '${(attendanceRate * 100).toStringAsFixed(1)}% present on $dateStr',
                          child: Container(
                            width: 20,
                            height: 80 * attendanceRate,
                            decoration: BoxDecoration(
                              color: Colors.red.shade700,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),

              // X-axis labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:
                    recentDates
                        .map(
                          (dateStr) => SizedBox(
                            width: 20,
                            child: Text(
                              dateStr,
                              style: const TextStyle(fontSize: 9),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                        .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceHistoryList(Map<String, dynamic> course) {
    // Get the current week's start and end dates
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: FirestoreService().getAttendanceForCourse(
        int.tryParse(course['id'].toString()) ?? 0,
        startDate: startOfWeek,
        endDate: endOfWeek,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final attendanceRecords = snapshot.data ?? [];
        if (attendanceRecords.isEmpty) {
          return const Center(
            child: Text(
              'No attendance records for this week. Take attendance to see records here.',
              textAlign: TextAlign.center,
            ),
          );
        }

        // Group attendance by date
        Map<String, List<Map<String, dynamic>>> attendanceByDate = {};
        for (var record in attendanceRecords) {
          final date = (record['date'] as Timestamp).toDate();
          final dateStr = '${date.year}-${date.month}-${date.day}';

          if (!attendanceByDate.containsKey(dateStr)) {
            attendanceByDate[dateStr] = [];
          }
          attendanceByDate[dateStr]!.add(record);
        }

        // Sort dates (most recent first)
        final sortedDates =
            attendanceByDate.keys.toList()..sort((a, b) => b.compareTo(a));

        return ListView.builder(
          itemCount: sortedDates.length,
          itemBuilder: (context, index) {
            final dateStr = sortedDates[index];
            final records = attendanceByDate[dateStr]!;

            // Parse the date
            final dateParts = dateStr.split('-');
            final date = DateTime(
              int.parse(dateParts[0]),
              int.parse(dateParts[1]),
              int.parse(dateParts[2]),
            );

            // Calculate attendance stats
            final totalStudents = records.length;
            final presentStudents =
                records.where((r) => r['isPresent'] == true).length;
            final absentStudents = totalStudents - presentStudents;
            final attendanceRate =
                totalStudents > 0
                    ? (presentStudents / totalStudents * 100).toStringAsFixed(1)
                    : '0.0';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              child: ExpansionTile(
                title: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Colors.red.shade900,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${date.day}/${date.month}/${date.year}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    // Visual attendance indicator
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value:
                                totalStudents > 0
                                    ? presentStudents / totalStudents
                                    : 0,
                            backgroundColor: Colors.red.shade100,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$attendanceRate%',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Chip(
                          label: Text('$presentStudents Present'),
                          backgroundColor: Colors.green.shade100,
                          labelStyle: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 8),
                        Chip(
                          label: Text('$absentStudents Absent'),
                          backgroundColor: Colors.red.shade100,
                          labelStyle: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.grey.shade50,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Student',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade900,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                'Status',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade900,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(width: 40),
                          ],
                        ),
                        const Divider(),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: records.length,
                          itemBuilder: (context, recordIndex) {
                            final record = records[recordIndex];
                            int studentId = record['studentId'] ?? 0;

                            return FutureBuilder<Map<String, dynamic>?>(
                              future: FirebaseFirestore.instance
                                  .collection('students')
                                  .doc(studentId.toString())
                                  .get()
                                  .then((doc) => doc.data()),
                              builder: (context, studentSnapshot) {
                                String studentName = 'Loading...';
                                if (studentSnapshot.hasData &&
                                    studentSnapshot.data != null) {
                                  studentName =
                                      studentSnapshot.data!['name'] ??
                                      'Unknown';
                                }

                                return Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.grey.shade200,
                                      child: Text(
                                        studentName.isNotEmpty
                                            ? studentName[0].toUpperCase()
                                            : '?',
                                      ),
                                    ),
                                    title: Text(studentName),
                                    subtitle: Text('ID: $studentId'),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                record['isPresent']
                                                    ? Colors.green.shade100
                                                    : Colors.red.shade100,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            record['isPresent']
                                                ? 'Present'
                                                : 'Absent',
                                            style: TextStyle(
                                              color:
                                                  record['isPresent']
                                                      ? Colors.green.shade800
                                                      : Colors.red.shade800,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            size: 20,
                                          ),
                                          onPressed:
                                              () => _editAttendanceRecord(
                                                course,
                                                studentId,
                                                record,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showTakeAttendanceDialog(
    Map<String, dynamic> course,
    List<Map<String, dynamic>> students,
  ) {
    // Create a map to hold attendance status for each student
    Map<int, bool> attendanceStatus = {};
    // Initialize all as present
    for (var student in students) {
      attendanceStatus[student['id']] = true;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Take Attendance - ${course['code']}'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final student = students[index];
                          final studentId = student['id'];

                          return CheckboxListTile(
                            title: Text(student['name']),
                            subtitle: Text('ID: $studentId'),
                            value: attendanceStatus[studentId],
                            onChanged: (value) {
                              setState(() {
                                attendanceStatus[studentId] = value ?? false;
                              });
                            },
                            activeColor: Colors.green,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (!mounted) return;
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade900,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    // Save attendance records
                    final firestoreService = FirestoreService();
                    final courseId = int.tryParse(course['id'].toString()) ?? 0;
                    final now = DateTime.now();

                    try {
                      // Save each student's attendance
                      for (var student in students) {
                        final studentId = student['id'];
                        await firestoreService.recordAttendance(
                          studentId: studentId,
                          courseId: courseId,
                          date: now,
                          isPresent: attendanceStatus[studentId] ?? false,
                        );
                      }

                      if (mounted) {
                        // Close dialog and show success message
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Attendance saved successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );

                        // Force rebuild for attendance history
                        setState(() {});
                      }
                    } catch (e) {
                      if (mounted) {
                        // Show error message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error saving attendance: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Save Attendance'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _editAttendanceRecord(
    Map<String, dynamic> course,
    int studentId,
    Map<String, dynamic> record,
  ) {
    bool isPresent = record['isPresent'] ?? false;
    String notes = record['notes'] ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Attendance Record'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FutureBuilder<Map<String, dynamic>?>(
                    future: FirebaseFirestore.instance
                        .collection('students')
                        .doc(studentId.toString())
                        .get()
                        .then((doc) => doc.data()),
                    builder: (context, snapshot) {
                      final studentName =
                          snapshot.data?['name'] ?? 'Loading...';
                      return ListTile(
                        title: Text(studentName),
                        subtitle: Text('Student ID: $studentId'),
                      );
                    },
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('Attendance Status'),
                    subtitle: Text(isPresent ? 'Present' : 'Absent'),
                    value: isPresent,
                    activeColor: Colors.green,
                    onChanged: (value) {
                      setState(() {
                        isPresent = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    controller: TextEditingController(text: notes),
                    onChanged: (value) {
                      notes = value;
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (!mounted) return;
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade900,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    try {
                      // Update the attendance record
                      final firestoreService = FirestoreService();
                      final courseId =
                          int.tryParse(course['id'].toString()) ?? 0;
                      final date = (record['date'] as Timestamp).toDate();

                      await firestoreService.recordAttendance(
                        studentId: studentId,
                        courseId: courseId,
                        date: date,
                        isPresent: isPresent,
                        notes: notes,
                      );

                      if (mounted) {
                        // Close dialog and show success message
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Attendance updated!'),
                            backgroundColor: Colors.green,
                          ),
                        );

                        // Force rebuild
                        setState(() {});
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error updating attendance: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

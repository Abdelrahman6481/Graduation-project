// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class AttendancePage extends StatefulWidget {
  final Map<String, dynamic>? student;
  final Map<String, dynamic>? instructor;
  final String userType;

  const AttendancePage({
    super.key,
    this.student,
    this.instructor,
    this.userType = 'student',
  });

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = true;
  int _studentId = 0;
  int _instructorId = 0;
  List<CourseAttendance> _courses = [];
  String _userName = '';
  bool _useTestData = false;
  List<Map<String, dynamic>> _instructorCourses = [];
  String _userRole = '';
  String _loadingError = '';
  // Stream subscription for real-time attendance updates
  StreamSubscription<List<Map<String, dynamic>>>? _attendanceStreamSubscription;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    // Cancel the stream subscription when the widget is disposed
    _attendanceStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _courses = [];
      _loadingError = '';
    });

    try {
      if (widget.userType == 'student') {
        _userRole = 'student';
        await _loadStudentData();
      } else if (widget.userType == 'instructor') {
        _userRole = 'instructor';
        await _loadInstructorData();
      } else {
        _userRole = 'unknown';
        _useTestData = true;
        _loadTestData();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading attendance data: $e');
      }
      _loadingError =
          'Failed to load attendance data: ${e.toString().substring(0, Math.min(100, e.toString().length))}';
      _useTestData = true;
      _loadTestData();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadStudentData() async {
    try {
      // Get student ID - first check if passed in widget, otherwise use shared preferences
      if (widget.student != null && widget.student!['id'] != null) {
        _studentId = int.tryParse(widget.student!['id'].toString()) ?? 0;
        _userName = widget.student!['name']?.toString() ?? 'Student';
      } else {
        final prefs = await SharedPreferences.getInstance();
        _studentId = prefs.getInt('studentId') ?? 0;
        _userName = prefs.getString('studentName') ?? 'Student';
      }

      if (_studentId == 0) {
        // Use test data instead of throwing an exception
        _useTestData = true;
        _loadTestData();
        return;
      }

      try {
        // Get all course registrations for this student
        final registrations = await _firestoreService.getStudentRegistrations(
          _studentId,
        );

        if (registrations.isEmpty) {
          // If no registrations, use test data
          _useTestData = true;
          _loadTestData();
          return;
        }

        // Map to store course data for each course ID
        Map<int, Map<String, dynamic>> coursesData = {};
        Map<int, String> instructorNames = {};

        // First, get all course data and instructor names
        for (var registration in registrations) {
          if (registration.status != 'active') continue;

          final courseId = registration.courseId;
          final courseDoc =
              await FirebaseFirestore.instance
                  .collection('courses')
                  .doc(courseId.toString())
                  .get();

          if (!courseDoc.exists || courseDoc.data() == null) continue;

          final courseData = courseDoc.data()!;
          coursesData[courseId] = courseData;

          // Get instructor name
          String instructorName = await _getInstructorNameForCourse(
            courseId,
            courseData,
          );
          instructorNames[courseId] = instructorName;
        }

        // Cancel any existing subscription
        await _attendanceStreamSubscription?.cancel();

        // Subscribe to real-time attendance updates for this student
        _attendanceStreamSubscription = _firestoreService
            .getAllAttendanceStreamForStudent(_studentId)
            .listen(
              (attendanceRecords) {
                if (!mounted) return;

                // Group attendance records by course
                Map<int, List<Map<String, dynamic>>> attendanceByCourseid = {};

                for (var record in attendanceRecords) {
                  final courseId = record['courseId'];
                  if (courseId == null) continue;

                  if (!attendanceByCourseid.containsKey(courseId)) {
                    attendanceByCourseid[courseId] = [];
                  }
                  attendanceByCourseid[courseId]!.add(record);
                }

                // Process each course's attendance data
                List<CourseAttendance> updatedCourses = [];

                for (var courseId in coursesData.keys) {
                  final courseData = coursesData[courseId]!;
                  final instructorName =
                      instructorNames[courseId] ?? 'Course Instructor';
                  final courseAttendanceRecords =
                      attendanceByCourseid[courseId] ?? [];

                  // Calculate attendance stats
                  int totalClasses = courseAttendanceRecords.length;
                  int attendedClasses =
                      courseAttendanceRecords
                          .where((record) => record['isPresent'] == true)
                          .length;
                  double attendancePercentage =
                      totalClasses > 0
                          ? (attendedClasses / totalClasses) * 100
                          : 0;

                  // Find the most recent attendance
                  DateTime lastAttendance = DateTime.now();
                  if (courseAttendanceRecords.isNotEmpty) {
                    final sortedRecords = List<Map<String, dynamic>>.from(
                      courseAttendanceRecords,
                    )..sort((a, b) {
                      final dateA = a['date'] as Timestamp?;
                      final dateB = b['date'] as Timestamp?;
                      if (dateA == null || dateB == null) return 0;
                      return dateB.compareTo(dateA);
                    });

                    if (sortedRecords.isNotEmpty &&
                        sortedRecords.first['date'] != null) {
                      lastAttendance =
                          (sortedRecords.first['date'] as Timestamp).toDate();
                    }
                  }

                  // Add to our courses list
                  updatedCourses.add(
                    CourseAttendance(
                      name: courseData['name']?.toString() ?? 'Unknown Course',
                      code: courseData['code']?.toString() ?? 'Unknown Code',
                      attendancePercentage: attendancePercentage,
                      totalClasses: totalClasses,
                      attendedClasses: attendedClasses,
                      lastAttendance: lastAttendance,
                      color: _getRandomColor(courseId),
                      instructor: instructorName,
                    ),
                  );
                }

                // Update the UI with the new data
                setState(() {
                  _courses = updatedCourses;
                  _isLoading = false;
                });
              },
              onError: (error) {
                if (kDebugMode) {
                  debugPrint('Error in attendance stream: $error');
                }
                if (mounted) {
                  setState(() {
                    _loadingError = 'Error loading attendance data: $error';
                    _isLoading = false;
                  });
                }
              },
            );

        // Initial load of data
        final allAttendanceRecords =
            await _firestoreService
                .getAllAttendanceStreamForStudent(_studentId)
                .first;

        if (allAttendanceRecords.isEmpty && mounted) {
          setState(() {
            _isLoading = false;
            _loadingError = 'No attendance records found.';
          });
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error loading registrations: $e');
        }
        _useTestData = true;
        _loadTestData();
        return;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error in student data load: $e');
      }
      _useTestData = true;
      _loadTestData();
    }
  }

  Future<void> _loadInstructorData() async {
    try {
      // Get instructor ID
      if (widget.instructor != null && widget.instructor!['id'] != null) {
        _instructorId = int.tryParse(widget.instructor!['id'].toString()) ?? 0;
        _userName = widget.instructor!['name']?.toString() ?? 'Instructor';
      } else {
        final prefs = await SharedPreferences.getInstance();
        _instructorId = prefs.getInt('instructorId') ?? 0;
        _userName = prefs.getString('instructorName') ?? 'Instructor';
      }

      if (_instructorId == 0) {
        // Use test data
        _useTestData = true;
        _loadTestData();
        return;
      }

      // Get instructor's courses
      final instructorDoc =
          await FirebaseFirestore.instance
              .collection('instructors')
              .doc(_instructorId.toString())
              .get();

      if (!instructorDoc.exists || instructorDoc.data() == null) {
        _useTestData = true;
        _loadTestData();
        return;
      }

      final data = instructorDoc.data()!;
      final assignedCourses = data['assignedCourses'];

      // Check if assignedCourses is null or not a List
      if (assignedCourses == null) {
        _useTestData = true;
        _loadTestData();
        return;
      }

      // Convert to List<String> safely
      List<String> courseIds = [];
      if (assignedCourses is List) {
        for (var item in assignedCourses) {
          if (item != null) {
            courseIds.add(item.toString());
          }
        }
      }

      if (courseIds.isEmpty) {
        _useTestData = true;
        _loadTestData();
        return;
      }

      // For each course, get attendance data
      for (var courseId in courseIds) {
        final courseDoc =
            await FirebaseFirestore.instance
                .collection('courses')
                .doc(courseId)
                .get();

        if (!courseDoc.exists || courseDoc.data() == null) continue;
        final courseData = courseDoc.data()!;

        try {
          // Get all attendance records for this course
          final attendanceRecords = await _firestoreService
              .getAttendanceForCourse(int.tryParse(courseId) ?? 0);

          if (attendanceRecords.isEmpty) continue;

          // Calculate course stats
          int totalStudents = await _countEnrolledStudents(
            int.tryParse(courseId) ?? 0,
          );
          int totalSessions = _countAttendanceSessions(attendanceRecords);

          // Calculate average attendance for the course
          double averageAttendance = _calculateAverageAttendance(
            attendanceRecords,
            totalStudents,
            totalSessions,
          );

          // Find the most recent session
          DateTime? lastSession;
          if (attendanceRecords.isNotEmpty) {
            final sortedRecords = List<Map<String, dynamic>>.from(
              attendanceRecords,
            )..sort((a, b) {
              final dateA = a['date'] as Timestamp?;
              final dateB = b['date'] as Timestamp?;
              if (dateA == null || dateB == null) return 0;
              return dateB.compareTo(dateA);
            });

            if (sortedRecords.isNotEmpty &&
                sortedRecords.first['date'] != null) {
              lastSession = (sortedRecords.first['date'] as Timestamp).toDate();
            }
          }

          // Add to courses list
          _courses.add(
            CourseAttendance(
              name: courseData['name']?.toString() ?? 'Unknown Course',
              code: courseData['code']?.toString() ?? 'Unknown Code',
              attendancePercentage: averageAttendance,
              totalClasses: totalSessions,
              attendedClasses:
                  (averageAttendance * totalSessions / 100).round(),
              lastAttendance: lastSession ?? DateTime.now(),
              color: _getRandomColor(int.tryParse(courseId) ?? 0),
              instructor: _userName,
              totalStudents: totalStudents,
            ),
          );
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Error processing course $courseId: $e');
          }
        }
      }

      if (_courses.isEmpty) {
        _useTestData = true;
        _loadTestData();
        return;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error in instructor data load: $e');
      }
      _useTestData = true;
      _loadTestData();
    }
  }

  Future<int> _countEnrolledStudents(int courseId) async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('courseRegistrations')
              .where('courseId', isEqualTo: courseId.toString())
              .where('status', isEqualTo: 'active')
              .get();

      return snapshot.docs.length;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error counting enrolled students: $e');
      }
      return 0;
    }
  }

  int _countAttendanceSessions(List<Map<String, dynamic>> attendanceData) {
    // Group by date to count unique sessions
    final sessions = <String>{};

    for (var record in attendanceData) {
      final timestamp = record['date'] as Timestamp?;
      if (timestamp == null) continue;

      final date = timestamp.toDate();
      final dateStr = '${date.year}-${date.month}-${date.day}';
      sessions.add(dateStr);
    }

    return sessions.length;
  }

  double _calculateAverageAttendance(
    List<Map<String, dynamic>> attendanceData,
    int totalStudents,
    int totalSessions,
  ) {
    if (totalStudents == 0 || totalSessions == 0) return 0;

    // Group records by session dates
    Map<String, List<Map<String, dynamic>>> sessionRecords = {};

    for (var record in attendanceData) {
      final timestamp = record['date'] as Timestamp?;
      if (timestamp == null) continue;

      final date = timestamp.toDate();
      final dateStr = '${date.year}-${date.month}-${date.day}';

      if (!sessionRecords.containsKey(dateStr)) {
        sessionRecords[dateStr] = [];
      }

      sessionRecords[dateStr]!.add(record);
    }

    // For each session, count how many present
    double totalAttendanceRate = 0;
    for (var session in sessionRecords.values) {
      int presentCount = session.where((r) => r['isPresent'] == true).length;
      double sessionRate =
          totalStudents > 0 ? (presentCount / totalStudents) * 100 : 0;
      totalAttendanceRate += sessionRate;
    }

    return sessionRecords.isNotEmpty
        ? totalAttendanceRate / sessionRecords.length
        : 0;
  }

  Future<void> _loadTestData() async {
    try {
      // Attempt to get real course data from Firestore
      final coursesSnapshot =
          await FirebaseFirestore.instance
              .collection('courses')
              .limit(10)
              .get();

      if (coursesSnapshot.docs.isNotEmpty) {
        List<CourseAttendance> fetchedCourses = [];

        for (var courseDoc in coursesSnapshot.docs) {
          if (!courseDoc.exists) continue;

          final courseData = courseDoc.data();
          final courseId = int.tryParse(courseDoc.id) ?? 0;
          if (courseId == 0) continue;

          // Get instructor information - improved lookup strategy
          String instructorName = await _getInstructorNameForCourse(
            courseId,
            courseData,
          );
          int totalStudents = 0;

          try {
            // Count enrolled students
            final registrationsSnapshot =
                await FirebaseFirestore.instance
                    .collection('courseRegistrations')
                    .where('courseId', isEqualTo: courseId.toString())
                    .where('status', isEqualTo: 'active')
                    .get();

            totalStudents = registrationsSnapshot.docs.length;

            // Get attendance records
            final attendanceRecords = await _firestoreService
                .getAttendanceForCourse(courseId);

            // Calculate stats
            int totalSessions = _countAttendanceSessions(attendanceRecords);
            double averageAttendance = _calculateAverageAttendance(
              attendanceRecords,
              totalStudents,
              totalSessions,
            );

            // Find last attendance date
            DateTime lastAttendance = DateTime.now();
            if (attendanceRecords.isNotEmpty) {
              final sortedRecords = List<Map<String, dynamic>>.from(
                attendanceRecords,
              )..sort((a, b) {
                final dateA = a['date'] as Timestamp?;
                final dateB = b['date'] as Timestamp?;
                if (dateA == null || dateB == null) return 0;
                return dateB.compareTo(dateA);
              });

              if (sortedRecords.isNotEmpty &&
                  sortedRecords.first['date'] != null) {
                lastAttendance =
                    (sortedRecords.first['date'] as Timestamp).toDate();
              }
            }

            // Select a color based on course ID
            final color = _getRandomColor(courseId);

            fetchedCourses.add(
              CourseAttendance(
                name: courseData['name']?.toString() ?? 'Unknown Course',
                code: courseData['code']?.toString() ?? 'Unknown Code',
                attendancePercentage: averageAttendance,
                totalClasses: max(totalSessions, 1), // Ensure at least 1 class
                attendedClasses:
                    (averageAttendance * max(totalSessions, 1) / 100).round(),
                lastAttendance: lastAttendance,
                color: color,
                instructor: instructorName,
                totalStudents: totalStudents,
              ),
            );
          } catch (e) {
            if (kDebugMode) {
              debugPrint('Error getting course details: $e');
            }
          }
        }

        // Use the fetched courses
        setState(() {
          _courses = fetchedCourses;
          _isLoading = false;
          _userName = _userName.isEmpty ? 'User' : _userName;
          _loadingError = '';
        });
        return;
      }

      // No courses found
      setState(() {
        _courses = [];
        _isLoading = false;
        _loadingError = 'No courses found in the database.';
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading data from Firestore: $e');
      }
      setState(() {
        _courses = [];
        _isLoading = false;
        _loadingError = 'Failed to load courses: ${e.toString()}';
      });
    }
  }

  // Comprehensive instructor name lookup function
  Future<String> _getInstructorNameForCourse(
    int courseId,
    Map<String, dynamic> courseData,
  ) async {
    try {
      print(
        'Looking up instructor for course: ${courseData['name']} (ID: $courseId)',
      );

      // Method 1: Check if instructorName is directly in the course document
      if (courseData['instructorName'] != null) {
        final name = courseData['instructorName'].toString();
        print('Found direct instructor name in course: $name');
        return name;
      }

      // Method 2: Check alternate field names for instructor name
      if (courseData['instructor_name'] != null) {
        final name = courseData['instructor_name'].toString();
        print('Found instructor_name in course: $name');
        return name;
      }

      // Method 3: Check instructor reference in the course
      if (courseData['instructor'] != null) {
        final instructorIdValue = courseData['instructor'];
        final instructorId = int.tryParse(instructorIdValue.toString());

        if (instructorId != null) {
          // Try direct document lookup first
          try {
            final instructorDoc =
                await FirebaseFirestore.instance
                    .collection('instructors')
                    .doc(instructorId.toString())
                    .get();

            if (instructorDoc.exists && instructorDoc.data() != null) {
              final data = instructorDoc.data()!;
              for (String field in [
                'name',
                'fullName',
                'full_name',
                'displayName',
                'display_name',
              ]) {
                if (data[field] != null) {
                  print(
                    'Found instructor via instructor ID, field $field: ${data[field]}',
                  );
                  return data[field].toString();
                }
              }
            }
          } catch (e) {
            print('Error in direct instructor lookup: $e');
          }

          // Try query-based lookup if direct lookup fails
          try {
            final instructorsQuery =
                await FirebaseFirestore.instance
                    .collection('instructors')
                    .where('id', isEqualTo: instructorId.toString())
                    .limit(1)
                    .get();

            if (instructorsQuery.docs.isNotEmpty) {
              final data = instructorsQuery.docs.first.data();
              for (String field in [
                'name',
                'fullName',
                'full_name',
                'displayName',
                'display_name',
              ]) {
                if (data[field] != null) {
                  print(
                    'Found instructor via query, field $field: ${data[field]}',
                  );
                  return data[field].toString();
                }
              }
            }
          } catch (e) {
            print('Error in query-based instructor lookup: $e');
          }
        }
      }

      // Method 4: Check instructor assignments collection
      try {
        final instructorAssignmentQuery =
            await FirebaseFirestore.instance
                .collection('instructorAssignments')
                .where('courseId', isEqualTo: courseId.toString())
                .limit(1)
                .get();

        if (instructorAssignmentQuery.docs.isNotEmpty) {
          final assignment = instructorAssignmentQuery.docs.first.data();
          final assignedInstructorId = assignment['instructorId']?.toString();

          if (assignedInstructorId != null) {
            // Get instructor document
            final instructorDoc =
                await FirebaseFirestore.instance
                    .collection('instructors')
                    .doc(assignedInstructorId)
                    .get();

            if (instructorDoc.exists && instructorDoc.data() != null) {
              final data = instructorDoc.data()!;
              for (String field in [
                'name',
                'fullName',
                'full_name',
                'displayName',
                'display_name',
              ]) {
                if (data[field] != null) {
                  print(
                    'Found instructor via assignments, field $field: ${data[field]}',
                  );
                  return data[field].toString();
                }
              }
            }
          }
        }
      } catch (e) {
        print('Error checking instructor assignments: $e');
      }

      // Method 5: Check course_instructors collection
      try {
        final courseInstructorQuery =
            await FirebaseFirestore.instance
                .collection('course_instructors')
                .where('course_id', isEqualTo: courseId.toString())
                .limit(1)
                .get();

        if (courseInstructorQuery.docs.isEmpty) {
          // Try alternate field name
          final altQuery =
              await FirebaseFirestore.instance
                  .collection('course_instructors')
                  .where('courseId', isEqualTo: courseId.toString())
                  .limit(1)
                  .get();

          if (altQuery.docs.isNotEmpty) {
            final mapping = altQuery.docs.first.data();
            final mappedInstructorId =
                mapping['instructorId'] ?? mapping['instructor_id'];

            if (mappedInstructorId != null) {
              final instructorDoc =
                  await FirebaseFirestore.instance
                      .collection('instructors')
                      .doc(mappedInstructorId.toString())
                      .get();

              if (instructorDoc.exists && instructorDoc.data() != null) {
                final data = instructorDoc.data()!;
                for (String field in [
                  'name',
                  'fullName',
                  'full_name',
                  'displayName',
                  'display_name',
                ]) {
                  if (data[field] != null) {
                    print(
                      'Found instructor via course_instructors mapping, field $field: ${data[field]}',
                    );
                    return data[field].toString();
                  }
                }
              }
            }
          }
        }
      } catch (e) {
        print('Error checking course_instructors: $e');
      }

      // Method 6: Check faculty collection as last resort
      try {
        final facultyQuery =
            await FirebaseFirestore.instance
                .collection('faculty')
                .where('courses', arrayContains: courseId.toString())
                .limit(1)
                .get();

        if (facultyQuery.docs.isNotEmpty) {
          final faculty = facultyQuery.docs.first.data();
          if (faculty['name'] != null) {
            print(
              'Found instructor via faculty collection: ${faculty['name']}',
            );
            return faculty['name'].toString();
          }
        }
      } catch (e) {
        print('Error checking faculty collection: $e');
      }

      // If we get here, we couldn't find an instructor name
      print(
        'No instructor found for course: ${courseData['name']} (ID: $courseId)',
      );
      return 'Dr. ${courseData['name']?.toString().split(' ').first ?? 'Course'} Instructor';
    } catch (e) {
      print('Error in instructor name lookup: $e');
      return 'Course Instructor';
    }
  }

  static int max(int a, int b) {
    return a > b ? a : b;
  }

  Color _getRandomColor(int courseId) {
    // Use the course ID to deterministically generate a color
    final List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
    ];

    return colors[courseId % colors.length];
  }

  Color _getAttendanceColor(double percentage) {
    if (percentage >= 90) return Colors.green;
    if (percentage >= 75) return Colors.orange;
    return Colors.red;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body:
          _isLoading
              ? _buildLoadingView()
              : _courses.isEmpty
              ? _buildEmptyView()
              : CustomScrollView(
                slivers: [
                  _buildAppBar(),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildOverallAttendance(),
                          const SizedBox(height: 20),
                          _buildAttendanceChart(),
                          const SizedBox(height: 20),
                          _buildCoursesList(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Refresh data
          _loadData();
        },
        backgroundColor: Colors.red.shade900,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.red),
          const SizedBox(height: 16),
          Text(
            _loadingError.isEmpty
                ? 'Loading attendance data...'
                : 'Loading attendance data...\n$_loadingError',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.calendar_today_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No attendance data available',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            widget.userType == 'instructor'
                ? 'You have no active courses with attendance records'
                : 'You have no active courses with attendance records',
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadData,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade900,
              foregroundColor: Colors.white,
            ),
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.red.shade900,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text('Attendance', style: TextStyle(color: Colors.white)),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Colors.red.shade900, Colors.red.shade900],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.calendar_today, color: Colors.white),
          onPressed: () {
            // Add calendar view functionality
          },
        ),
        IconButton(
          icon: const Icon(Icons.filter_list, color: Colors.white),
          onPressed: () {
            // Add filter functionality
          },
        ),
      ],
    );
  }

  Widget _buildOverallAttendance() {
    final overallPercentage =
        _courses.isEmpty
            ? 0.0
            : _courses
                    .map((c) => c.attendancePercentage)
                    .reduce((a, b) => a + b) /
                _courses.length;

    return FadeInDown(
      duration: const Duration(milliseconds: 500),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 5,
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.userType == 'instructor'
                        ? 'Overall Class Attendance'
                        : 'Overall Attendance',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getAttendanceColor(overallPercentage),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${overallPercentage.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: overallPercentage / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getAttendanceColor(overallPercentage),
              ),
              minHeight: 10,
              borderRadius: BorderRadius.circular(10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceChart() {
    final mainGreen = const Color(0xFFDDEED5);

    return FadeInDown(
      delay: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: mainGreen, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 5,
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Course Attendance Overview',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ..._courses.map(
              (course) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          course.code,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${course.attendancePercentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: course.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Stack(
                      children: [
                        Container(
                          height: 8,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        Container(
                          height: 8,
                          width:
                              MediaQuery.of(context).size.width *
                              (course.attendancePercentage / 100) *
                              0.7, // 0.7 to account for padding
                          decoration: BoxDecoration(
                            color: course.color,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ],
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

  Widget _buildCoursesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            'Course-wise Attendance',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ..._courses.map((course) => _buildCourseCard(course)),
      ],
    );
  }

  Widget _buildCourseCard(CourseAttendance course) {
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 5,
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        course.code,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      widget.userType == 'instructor'
                          ? Text(
                            'Students: ${course.totalStudents}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          )
                          : _buildInstructorNameWidget(course.instructor),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getAttendanceColor(course.attendancePercentage),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${course.attendancePercentage.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: course.attendancePercentage / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(course.color),
              minHeight: 8,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${course.attendedClasses}/${course.totalClasses} ${widget.userType == 'instructor' ? 'Sessions' : 'Classes'}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                Text(
                  'Last ${widget.userType == 'instructor' ? 'session' : 'attended'}: ${_formatDate(course.lastAttendance)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to properly display instructor name
  Widget _buildInstructorNameWidget(String instructorName) {
    // Check if instructor name is empty, null, or "Unknown"
    final bool isUnknown =
        instructorName.isEmpty ||
        instructorName == 'Unknown' ||
        instructorName == 'Unknown Instructor';

    // If the instructor name starts with "Instructor #", extract just the name portion
    String displayName = instructorName;
    if (displayName.startsWith('Instructor #')) {
      displayName = 'Instructor';
    }

    return Row(
      children: [
        // Instructor icon
        Icon(
          Icons.person,
          size: 12,
          color: isUnknown ? Colors.grey : Colors.grey[600],
        ),
        const SizedBox(width: 4),
        // Instructor name
        Flexible(
          child: Text(
            isUnknown ? 'Course Instructor' : displayName,
            style: TextStyle(
              color: isUnknown ? Colors.grey : Colors.grey[600],
              fontSize: 12,
              fontStyle: isUnknown ? FontStyle.italic : FontStyle.normal,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class CourseAttendance {
  final String name;
  final String code;
  final double attendancePercentage;
  final int totalClasses;
  final int attendedClasses;
  final DateTime lastAttendance;
  final Color color;
  final String instructor;
  final int totalStudents;

  CourseAttendance({
    required this.name,
    required this.code,
    required this.attendancePercentage,
    required this.totalClasses,
    required this.attendedClasses,
    required this.lastAttendance,
    required this.color,
    this.instructor = 'Course Instructor',
    this.totalStudents = 0,
  });
}

class Math {
  static int min(int a, int b) {
    return a < b ? a : b;
  }
}

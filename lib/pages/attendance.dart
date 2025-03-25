import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final List<CourseAttendance> courses = [
    CourseAttendance(
      name: 'Software Engineering',
      code: 'CSE401',
      attendancePercentage: 85,
      totalClasses: 20,
      attendedClasses: 17,
      lastAttendance: DateTime.now().subtract(const Duration(days: 2)),
      color: Colors.blue,
    ),
    CourseAttendance(
      name: 'Database Systems',
      code: 'CSE402',
      attendancePercentage: 90,
      totalClasses: 15,
      attendedClasses: 14,
      lastAttendance: DateTime.now().subtract(const Duration(days: 1)),
      color: Colors.green,
    ),
    CourseAttendance(
      name: 'Computer Networks',
      code: 'CSE403',
      attendancePercentage: 75,
      totalClasses: 18,
      attendedClasses: 13,
      lastAttendance: DateTime.now().subtract(const Duration(days: 3)),
      color: Colors.orange,
    ),
    CourseAttendance(
      name: 'Artificial Intelligence',
      code: 'CSE404',
      attendancePercentage: 95,
      totalClasses: 12,
      attendedClasses: 11,
      lastAttendance: DateTime.now().subtract(const Duration(days: 4)),
      color: Colors.purple,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
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
          // Add functionality to view detailed attendance history
        },
        backgroundColor: Colors.red.shade900,
        child: const Icon(Icons.history, color: Colors.white),
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
        courses.isEmpty
            ? 0.0
            : courses
                    .map((c) => c.attendancePercentage)
                    .reduce((a, b) => a + b) /
                courses.length;

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
                const Text(
                  'Overall Attendance',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
    final mainGreen = const Color(0xFFDDEED5); // الأخضر الفاتح الأساسي
    final darkRed = const Color(0xFF8B0000); // الأحمر الداكن الأساسي

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
            ...courses
                .map(
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
                              '${course.attendancePercentage}%',
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
                )
                .toList(),
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
        ...courses.map((course) => _buildCourseCard(course)).toList(),
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
                      ),
                      Text(
                        course.code,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
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
                    '${course.attendancePercentage}%',
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
                  '${course.attendedClasses}/${course.totalClasses} Classes',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                Text(
                  'Last attended: ${_formatDate(course.lastAttendance)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getAttendanceColor(double percentage) {
    if (percentage >= 90) return Colors.green;
    if (percentage >= 75) return Colors.orange;
    return Colors.red;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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

  CourseAttendance({
    required this.name,
    required this.code,
    required this.attendancePercentage,
    required this.totalClasses,
    required this.attendedClasses,
    required this.lastAttendance,
    required this.color,
  });
}

import 'package:flutter/material.dart';

class CourseActivityGradePage extends StatelessWidget {
  const CourseActivityGradePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Activity Grades'),
        backgroundColor: Colors.red.shade900,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSemesterSelector(),
            const SizedBox(height: 20),
            _buildCourseGradeCard(
              'Computer Architecture',
              'CS 301',
              'Dr. Ahmed Hassan',
              [
                GradeItem('Midterm Exam', 25, 20),
                GradeItem('Assignment 1', 10, 8),
                GradeItem('Assignment 2', 10, 9),
                GradeItem('Quiz 1', 5, 4),
                GradeItem('Quiz 2', 5, 5),
                GradeItem('Project', 15, 13),
                GradeItem('Final Exam', 30, 0, isCompleted: false),
              ],
            ),
            _buildCourseGradeCard(
              'Database Systems',
              'CS 305',
              'Dr. Mohamed Ali',
              [
                GradeItem('Midterm Exam', 20, 17),
                GradeItem('Assignment 1', 10, 9),
                GradeItem('Assignment 2', 10, 8),
                GradeItem('Quiz 1', 5, 4),
                GradeItem('Quiz 2', 5, 3),
                GradeItem('Project', 20, 18),
                GradeItem('Final Exam', 30, 0, isCompleted: false),
              ],
            ),
            _buildCourseGradeCard(
              'Software Engineering',
              'CS 310',
              'Dr. Sara Ahmed',
              [
                GradeItem('Midterm Exam', 20, 16),
                GradeItem('Assignment 1', 5, 5),
                GradeItem('Assignment 2', 5, 4),
                GradeItem('Assignment 3', 5, 5),
                GradeItem('Quiz 1', 5, 4),
                GradeItem('Quiz 2', 5, 5),
                GradeItem('Project', 25, 22),
                GradeItem('Final Exam', 30, 0, isCompleted: false),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSemesterSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Spring 2024',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 16),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 16),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCourseGradeCard(
    String courseName,
    String courseCode,
    String instructor,
    List<GradeItem> gradeItems,
  ) {
    // Calculate total earned and total possible
    double totalEarned = 0;
    double totalPossible = 0;
    double completedPossible = 0;

    for (var item in gradeItems) {
      totalEarned += item.earned;
      totalPossible += item.possible;
      if (item.isCompleted) {
        completedPossible += item.possible;
      }
    }

    // Calculate percentage
    double percentage =
        completedPossible > 0 ? (totalEarned / completedPossible) * 100 : 0;

    // Determine grade status
    String gradeStatus = '';
    Color statusColor = Colors.grey;

    if (percentage >= 90) {
      gradeStatus = 'Excellent';
      statusColor = Colors.green;
    } else if (percentage >= 80) {
      gradeStatus = 'Very Good';
      statusColor = Colors.blue;
    } else if (percentage >= 70) {
      gradeStatus = 'Good';
      statusColor = Colors.amber.shade700;
    } else if (percentage >= 60) {
      gradeStatus = 'Pass';
      statusColor = Colors.orange;
    } else {
      gradeStatus = 'Needs Improvement';
      statusColor = Colors.red;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    courseName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade900,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    courseCode,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              'Instructor: $instructor',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Grade',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${percentage.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '($totalEarned/$completedPossible)',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Status',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        gradeStatus,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            const Divider(),
            const SizedBox(height: 10),
            const Text(
              'Grade Breakdown',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...gradeItems.map((item) => _buildGradeItemRow(item)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeItemRow(GradeItem item) {
    final percentage =
        item.possible > 0 ? (item.earned / item.possible) * 100 : 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              item.name,
              style: TextStyle(
                color: item.isCompleted ? Colors.black87 : Colors.grey,
                fontStyle:
                    item.isCompleted ? FontStyle.normal : FontStyle.italic,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${item.possible}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: item.isCompleted ? Colors.black87 : Colors.grey,
                fontStyle:
                    item.isCompleted ? FontStyle.normal : FontStyle.italic,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              item.isCompleted ? '${item.earned}' : '-',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: item.isCompleted ? Colors.black87 : Colors.grey,
                fontStyle:
                    item.isCompleted ? FontStyle.normal : FontStyle.italic,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              item.isCompleted ? '${percentage.toStringAsFixed(0)}%' : '-',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontStyle:
                    item.isCompleted ? FontStyle.normal : FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPercentageColor(double percentage) {
    if (!percentage.isFinite || percentage <= 0) return Colors.grey;
    if (percentage >= 90) return Colors.green;
    if (percentage >= 80) return Colors.blue;
    if (percentage >= 70) return Colors.amber.shade700;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }
}

class GradeItem {
  final String name;
  final double possible;
  final double earned;
  final bool isCompleted;

  GradeItem(this.name, this.possible, this.earned, {this.isCompleted = true});
}

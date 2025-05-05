import 'package:flutter/material.dart';

class ExamSchedulePage extends StatelessWidget {
  const ExamSchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Schedule'),
        backgroundColor: Colors.red.shade900,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upcoming Exams',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            _buildExamCard(
              'Computer Architecture',
              'CS 301',
              'Final Exam',
              DateTime(2024, 5, 15, 10, 0),
              'Hall A',
              'Dr. Ahmed Hassan',
            ),
            _buildExamCard(
              'Database Systems',
              'CS 305',
              'Midterm Exam',
              DateTime(2024, 5, 20, 12, 30),
              'Hall B',
              'Dr. Mohamed Ali',
            ),
            _buildExamCard(
              'Software Engineering',
              'CS 310',
              'Final Exam',
              DateTime(2024, 5, 25, 9, 0),
              'Hall C',
              'Dr. Sara Ahmed',
            ),
            _buildExamCard(
              'Web Development',
              'CS 315',
              'Practical Exam',
              DateTime(2024, 5, 30, 14, 0),
              'Lab 3',
              'Dr. Khaled Ibrahim',
            ),
            const SizedBox(height: 20),
            const Text(
              'Past Exams',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            _buildExamCard(
              'Data Structures',
              'CS 201',
              'Final Exam',
              DateTime(2024, 4, 10, 10, 0),
              'Hall A',
              'Dr. Ahmed Hassan',
              isPast: true,
            ),
            _buildExamCard(
              'Algorithms',
              'CS 205',
              'Midterm Exam',
              DateTime(2024, 4, 5, 12, 30),
              'Hall B',
              'Dr. Mohamed Ali',
              isPast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamCard(
    String courseName,
    String courseCode,
    String examType,
    DateTime examDate,
    String location,
    String instructor, {
    bool isPast = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
                Text(
                  courseName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isPast ? Colors.grey : Colors.red.shade900,
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
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.event, size: 16, color: Colors.grey),
                const SizedBox(width: 5),
                Text(
                  '${examDate.day}/${examDate.month}/${examDate.year}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(width: 15),
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 5),
                Text(
                  '${examDate.hour}:${examDate.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Exam Type',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        examType,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Location',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        location,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Instructor',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            Text(
              instructor,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class ResultsPage extends StatefulWidget {
  const ResultsPage({super.key});

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _semesters = [
    'Fall 2023',
    'Spring 2023',
    'Fall 2022',
    'Spring 2022',
  ];

  // نموذج بيانات النتائج
  final Map<String, List<Map<String, dynamic>>> _results = {
    'Fall 2023': [
      {
        'course': 'Advanced Programming',
        'code': 'CS301',
        'grade': 'A',
        'points': 4.0,
        'credits': 3,
        'status': 'Passed',
      },
      {
        'course': 'Database Systems',
        'code': 'CS302',
        'grade': 'A-',
        'points': 3.7,
        'credits': 3,
        'status': 'Passed',
      },
    ],
    'Spring 2023': [
      {
        'course': 'Web Development',
        'code': 'CS305',
        'grade': 'A',
        'points': 4.0,
        'credits': 3,
        'status': 'Passed',
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _semesters.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red.shade900,
        elevation: 0,
        title: const Text(
          'Academic Results',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: () {
              // تنفيذ تحميل النتائج
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSemesterTabs(),
          _buildCGPA(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children:
                  _semesters.map((semester) {
                    return _buildResultsList(semester);
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSemesterTabs() {
    return Container(
      color: Colors.red.shade900,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: Colors.white,
        indicatorWeight: 3,
        tabs:
            _semesters.map((semester) {
              return Tab(
                child: Text(
                  semester,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildCGPA() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade900,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.red.shade900.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Cumulative GPA',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 10),
          const Text(
            '3.85',
            style: TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCGPAInfo('Total Credits', '69'),
              Container(
                height: 20,
                width: 1,
                color: Colors.white24,
                margin: const EdgeInsets.symmetric(horizontal: 20),
              ),
              _buildCGPAInfo('Total Points', '265.5'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCGPAInfo(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildResultsList(String semester) {
    List<Map<String, dynamic>>? semesterResults = _results[semester];

    if (semesterResults == null || semesterResults.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: semesterResults.length + 1, // +1 for semester summary
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildSemesterSummary(semesterResults);
        }
        return FadeInUp(
          duration: Duration(milliseconds: 300 + ((index - 1) * 100)),
          child: _buildResultCard(semesterResults[index - 1]),
        );
      },
    );
  }

  Widget _buildSemesterSummary(List<Map<String, dynamic>> results) {
    double totalPoints = 0;
    int totalCredits = 0;

    for (var result in results) {
      totalPoints += (result['points'] as double) * (result['credits'] as int);
      totalCredits += result['credits'] as int;
    }

    double gpa = totalPoints / totalCredits;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [Colors.red.shade800, Colors.red.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Semester GPA',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 5),
                Text(
                  gpa.toStringAsFixed(2),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Credits: $totalCredits',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 5),
                Text(
                  'Points: ${totalPoints.toStringAsFixed(1)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(Map<String, dynamic> result) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // تنفيذ عرض تفاصيل إضافية
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                          result['course'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          result['code'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildGradeChip(result['grade']),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildResultInfo(
                    Icons.star_outline,
                    'Points',
                    result['points'].toString(),
                  ),
                  _buildResultInfo(
                    Icons.book_outlined,
                    'Credits',
                    result['credits'].toString(),
                  ),
                  _buildResultInfo(
                    Icons.check_circle_outline,
                    'Status',
                    result['status'],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradeChip(String grade) {
    Color chipColor;
    if (grade.startsWith('A')) {
      chipColor = Colors.green;
    } else if (grade.startsWith('B')) {
      chipColor = Colors.blue;
    } else if (grade.startsWith('C')) {
      chipColor = Colors.orange;
    } else {
      chipColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: chipColor.withOpacity(0.5), width: 1),
      ),
      child: Text(
        grade,
        style: TextStyle(
          color: chipColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildResultInfo(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 80, color: Colors.red.shade200),
          const SizedBox(height: 16),
          Text(
            'No Results Available',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Results will appear here once published',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/firestore_service.dart';

class ResultsPage extends StatefulWidget {
  final Map<String, dynamic>? student;

  const ResultsPage({super.key, this.student});

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = true;
  int _studentId = 0;
  String _studentName = '';
  double _cgpa = 0.0;
  int _totalCredits = 0;
  double _totalPoints = 0.0;

  List<String> _semesters = [];
  Map<String, List<Map<String, dynamic>>> _results = {};

  @override
  void initState() {
    super.initState();
    //! هنعمل تاب كنترولر بتاب واحد في الأول عشان نتجنب إيرور الـ late initialization
    _tabController = TabController(length: 1, vsync: this);
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      //! هنجيب الـ ID بتاع الطالب - لو موجود في الـ widget هناخده، لو مش موجود هنجيبه من الـ shared preferences
      if (widget.student != null && widget.student!['id'] != null) {
        _studentId = int.tryParse(widget.student!['id'].toString()) ?? 0;
        _studentName = widget.student!['name']?.toString() ?? 'Student';
      } else {
        final prefs = await SharedPreferences.getInstance();
        _studentId = prefs.getInt('studentId') ?? 0;
        _studentName = prefs.getString('studentName') ?? 'Student';
      }

      if (_studentId == 0) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      //! هنجيب بيانات الطالب من الفايرستور
      final student = await _firestoreService.getStudent(_studentId);
      if (student == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      //! الخطوة الأولى: هنحاول نجيب النتايج المنشورة من كوليكشن studentResults
      final publishedResults = await _firestoreService
          .getStudentAcademicResults(_studentId);

      //! هنعمل ماب عشان ننظم النتايج حسب الترم
      Map<String, List<Map<String, dynamic>>> resultsBySemester = {};

      //! هنجهز النتايج المنشورة من كوليكشن studentResults
      if (publishedResults.isNotEmpty) {
        for (var result in publishedResults) {
          // هنشوف بس النتايج اللي اتنشرت فعلاً
          if (result['isPublished'] != true) continue;

          //! هنعمل فورمات للترم مع السنة الدراسية
          String semester = '${result['semester']} ${result['academicYear']}';
          if (!resultsBySemester.containsKey(semester)) {
            resultsBySemester[semester] = [];
          }

          //! هنجيب تفاصيل المادة
          final courseId = int.tryParse(result['courseId'].toString()) ?? 0;
          String courseName = result['courseName'] ?? 'Unknown Course';
          String courseCode = result['courseCode'] ?? '';
          int courseCredits =
              int.tryParse(result['courseCredits'].toString()) ?? 0;

          //! هنحول نتيجة الفايرستور للفورمات المناسب
          resultsBySemester[semester]!.add({
            'course': courseName,
            'code': courseCode,
            'grade': result['letterGrade'] ?? '-',
            'points': _getGradePoints(result['letterGrade'] ?? '-'),
            'credits': courseCredits,
            'status':
                _getGradePoints(result['letterGrade'] ?? '-') >= 1.0
                    ? 'Passed'
                    : 'Failed',
            'totalGrade': (result['totalGrade'] as num?)?.toDouble() ?? 0.0,
            'publishedDate':
                result['updatedAt'], // Store publish date for sorting if needed
          });
        }
      }

      //! الخطوة التانية: لو مفيش نتايج منشورة أو كباك أب، هنجرب نجيب من student.academicResults
      final academicResults = student.academicResults ?? [];
      if (resultsBySemester.isEmpty && academicResults.isNotEmpty) {
        //! هنجهز النتايج من student.academicResults
        for (var result in academicResults) {
          String semester = '${result['semester']} ${result['academicYear']}';
          if (!resultsBySemester.containsKey(semester)) {
            resultsBySemester[semester] = [];
          }

          resultsBySemester[semester]!.add({
            'course': result['courseName'],
            'code': result['courseCode'],
            'grade': result['grade'],
            'points': _getGradePoints(result['grade']),
            'credits': result['credits'],
            'status':
                _getGradePoints(result['grade']) >= 1.0 ? 'Passed' : 'Failed',
            'totalGrade': result['totalGrade'],
          });
        }
      }

      //! هنحدث الستيت بالنتايج ونحسب الإحصائيات
      setState(() {
        _results = resultsBySemester;
        _semesters =
            resultsBySemester.keys.toList()..sort(
              (a, b) => b.compareTo(a),
            ); //! هنرتب الترمات بحيث الأحدث يكون الأول

        if (student.gpa > 0) {
          //! هنستخدم بيانات الطالب لو موجودة
          _cgpa = student.gpa;
          _totalCredits = student.credits;
          _totalPoints = student.totalPoints.toDouble();
        } else {
          //! هنحسب من النتايج لو بيانات الطالب مفيهاش GPA
          _calculateOverallStats();
        }

        _isLoading = false;
      });

      //! هنحدث التاب كنترولر بالعدد الصحيح للتابات
      if (mounted) {
        setState(() {
          //! هنتأكد إن عندنا تاب واحد على الأقل، حتى لو مفيش ترمات
          final int tabCount = _semesters.isNotEmpty ? _semesters.length : 1;

          //! هنتخلص من الكنترولر القديم قبل ما نعمل واحد جديد
          _tabController.dispose();

          //! هنعمل كنترولر جديد بالعدد الصحيح للتابات
          _tabController = TabController(length: tabCount, vsync: this);
        });
      }
    } catch (e) {
      //! حصل إيرور في تحميل نتايج الطالب
      print('Error loading student results: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  //! دي الفنكشن اللي بتحسب الإحصائيات الكلية للطالب (المعدل التراكمي والساعات المعتمدة)
  void _calculateOverallStats() {
    double totalPoints = 0;
    int totalCredits = 0;

    _results.forEach((semester, courses) {
      for (var course in courses) {
        totalPoints +=
            (course['points'] as double) * (course['credits'] as int);
        totalCredits += course['credits'] as int;
      }
    });

    setState(() {
      _totalPoints = totalPoints;
      _totalCredits = totalCredits;
      _cgpa = totalCredits > 0 ? totalPoints / totalCredits : 0.0;
    });
  }

  //! دي الفنكشن اللي بتحول التقدير (A, B, C) لنقاط (4.0, 3.0, 2.0)
  double _getGradePoints(String grade) {
    switch (grade) {
      case 'A':
        return 4.0;
      case 'A-':
        return 3.7;
      case 'B+':
        return 3.3;
      case 'B':
        return 3.0;
      case 'B-':
        return 2.7;
      case 'C+':
        return 2.3;
      case 'C':
        return 2.0;
      case 'C-':
        return 1.7;
      case 'D+':
        return 1.3;
      case 'D':
        return 1.0;
      case 'F':
        return 0.0;
      default:
        return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red.shade900,
          elevation: 0,
          title: const Text(
            'Academic Results',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadStudentData,
            tooltip: 'Refresh results',
          ),
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: () {
              // Implement download functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Download feature coming soon')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_semesters.isNotEmpty) _buildSemesterTabs(),
          _buildCGPA(),
          Expanded(
            child:
                _semesters.isEmpty
                    ? _buildEmptyState()
                    : TabBarView(
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

  //! دي الفنكشن اللي بتبني تابات الترمات
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

  //! دي الفنكشن اللي بتبني جزء المعدل التراكمي
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
          Text(
            _cgpa.toStringAsFixed(2),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCGPAInfo('Total Credits', _totalCredits.toString()),
              Container(
                height: 20,
                width: 1,
                color: Colors.white24,
                margin: const EdgeInsets.symmetric(horizontal: 20),
              ),
              _buildCGPAInfo('Total Points', _totalPoints.toStringAsFixed(1)),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            _studentName,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // دي الفنكشن اللي بتبني معلومات المعدل التراكمي (الساعات والنقاط)
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

  // دي الفنكشن اللي بتبني قائمة النتايج للترم
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

  // دي الفنكشن اللي بتبني ملخص الترم (المعدل الفصلي والساعات)
  Widget _buildSemesterSummary(List<Map<String, dynamic>> results) {
    double totalPoints = 0;
    int totalCredits = 0;

    for (var result in results) {
      totalPoints += (result['points'] as double) * (result['credits'] as int);
      totalCredits += result['credits'] as int;
    }

    double gpa = totalCredits > 0 ? totalPoints / totalCredits : 0.0;

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

  //! دي الفنكشن اللي بتبني كارت النتيجة لكل مادة
  Widget _buildResultCard(Map<String, dynamic> result) {
    //! هنشوف لو النتيجة دي اتنشرت حديثاً (خلال آخر 7 أيام)
    bool isRecentlyPublished = false;
    if (result['publishedDate'] != null) {
      try {
        if (result['publishedDate'] is Timestamp) {
          final publishDate = (result['publishedDate'] as Timestamp).toDate();
          final now = DateTime.now();
          final difference = now.difference(publishDate);
          isRecentlyPublished = difference.inDays < 7;
        }
      } catch (e) {
        //! حصل إيرور في التحقق من تاريخ النشر
        print('Error checking publish date: $e');
      }
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          _showResultDetails(result);
        },
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Padding(
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
            if (isRecentlyPublished)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'NEW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  //! دي الفنكشن اللي بتعرض تفاصيل النتيجة لما ندوس على الكارت
  void _showResultDetails(Map<String, dynamic> result) {
    //! هنعمل فورمات لتاريخ النشر لو موجود
    String publishDate = '';
    if (result['publishedDate'] != null) {
      try {
        if (result['publishedDate'] is Timestamp) {
          final date = (result['publishedDate'] as Timestamp).toDate();
          publishDate = '${date.day}/${date.month}/${date.year}';
        }
      } catch (e) {
        //! حصل إيرور في فورمات تاريخ النشر
        print('Error formatting publish date: $e');
      }
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(result['course']),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Course Code: ${result['code']}'),
                const SizedBox(height: 8),
                Row(
                  children: [Text('Grade: '), _buildGradeChip(result['grade'])],
                ),
                const SizedBox(height: 8),
                Text(
                  'Total Score: ${result['totalGrade']?.toStringAsFixed(1) ?? "N/A"}',
                ),
                const SizedBox(height: 8),
                Text('Credits: ${result['credits']}'),
                const SizedBox(height: 8),
                Text('Status: ${result['status']}'),
                if (publishDate.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Published: $publishDate',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
                if (result['instructorName'] != null &&
                    result['instructorName'].toString().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Instructor: ${result['instructorName']}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  // دي الفنكشن اللي بتبني شكل التقدير (A, B, C) في الكارت
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
        color: Color.fromRGBO(
          chipColor.red,
          chipColor.green,
          chipColor.blue,
          0.1,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Color.fromRGBO(
            chipColor.red,
            chipColor.green,
            chipColor.blue,
            0.5,
          ),
          width: 1,
        ),
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

  //! دي الفنكشن اللي بتبني الشاشة الفاضية لما مفيش نتايج
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

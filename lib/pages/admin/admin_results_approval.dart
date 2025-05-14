import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';
import 'package:intl/intl.dart';

//! دي صفحة الأدمن اللي بيوافق فيها على نتايج الطلبة ويقدر ينشرها
class AdminResultsApprovalPage extends StatefulWidget {
  const AdminResultsApprovalPage({Key? key}) : super(key: key);

  @override
  State<AdminResultsApprovalPage> createState() =>
      _AdminResultsApprovalPageState();
}

class _AdminResultsApprovalPageState extends State<AdminResultsApprovalPage>
    with TickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _pendingResults = [];
  List<Map<String, dynamic>> _publishedResults = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadResults();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  //! هنا بنجيب النتايج من الداتابيز عشان نعرضها للأدمن
  Future<void> _loadResults() async {
    setState(() {
      _isLoading = true;
    });

    try {
      //! هنجيب النتايج اللي لسه مانشرتش (اللي محتاجة موافقة)
      final pendingResultsQuery =
          await FirebaseFirestore.instance
              .collection('studentResults')
              .where('isPublished', isEqualTo: false)
              .get();

      //! هنجيب النتايج اللي اتنشرت خلاص للطلبة
      final publishedResultsQuery =
          await FirebaseFirestore.instance
              .collection('studentResults')
              .where('isPublished', isEqualTo: true)
              .get();

      final List<Map<String, dynamic>> pendingResults = [];
      final List<Map<String, dynamic>> publishedResults = [];

      //! هنجهز النتايج اللي محتاجة موافقة عشان نعرضها
      for (var doc in pendingResultsQuery.docs) {
        final data = doc.data();
        pendingResults.add({'id': doc.id, ...data});
      }

      //!! هنجهز النتايج اللي اتنشرت خلاص عشان نعرضها
      for (var doc in publishedResultsQuery.docs) {
        final data = doc.data();
        publishedResults.add({'id': doc.id, ...data});
      }

      //! هنرتب النتايج حسب وقت التحديث (الأحدث الأول) عشان نشوف آخر النتايج
      pendingResults.sort((a, b) {
        final aTime = a['updatedAt'] as Timestamp?;
        final bTime = b['updatedAt'] as Timestamp?;
        if (aTime == null || bTime == null) return 0;
        return bTime.compareTo(aTime);
      });

      publishedResults.sort((a, b) {
        final aTime = a['updatedAt'] as Timestamp?;
        final bTime = b['updatedAt'] as Timestamp?;
        if (aTime == null || bTime == null) return 0;
        return bTime.compareTo(aTime);
      });

      setState(() {
        _pendingResults = pendingResults;
        _publishedResults = publishedResults;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading results: $e')));
      }
    }
  }

  //! دي الفنكشن اللي بتنشر نتيجة واحدة للطالب
  Future<void> _publishResult(String resultId) async {
    try {
      await FirebaseFirestore.instance
          .collection('studentResults')
          .doc(resultId)
          .update({
            'isPublished': true,
            'publishedAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      //! هنحدث القايمة عشان نشوف التغييرات
      await _loadResults();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Result published successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error publishing result: $e')));
      }
    }
  }

  //! دي الفنكشن اللي بتنشر كل نتايج المادة مرة واحدة
  Future<void> _publishAllResultsForCourse(String courseId) async {
    try {
      await _firestoreService.publishStudentResults(
        int.parse(courseId),
        publishAll: true,
      );

      //! هنحدث القايمة عشان نشوف التغييرات
      await _loadResults();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All course results published successfully'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error publishing course results: $e')),
        );
      }
    }
  }

  //! دي الفنكشن اللي بتلغي نشر النتيجة (لو فيه غلط مثلا)
  Future<void> _unpublishResult(String resultId) async {
    try {
      await FirebaseFirestore.instance
          .collection('studentResults')
          .doc(resultId)
          .update({
            'isPublished': false,
            'publishedAt': null,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      //! هنحدث القايمة عشان نشوف التغييرات
      await _loadResults();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Result unpublished successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error unpublishing result: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red.shade900,
        title: const Text(
          'Student Results Management',
          style: TextStyle(color: Colors.white),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Pending Results'),
            Tab(text: 'Published Results'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadResults,
            tooltip: 'Refresh Results',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                controller: _tabController,
                children: [
                  //!تاب النتايج اللي محتاجة موافقة
                  _buildPendingResultsTab(),
                  //! تاب النتايج اللي اتنشرت خلاص
                  _buildPublishedResultsTab(),
                ],
              ),
    );
  }

  //! هنا بنبني تاب النتايج اللي محتاجة موافقة
  Widget _buildPendingResultsTab() {
    if (_pendingResults.isEmpty) {
      return const Center(child: Text('No pending results to approve'));
    }

    //! هنجمع النتايج حسب المادة عشان نعرضها بشكل منظم
    final Map<String, List<Map<String, dynamic>>> resultsByCourse = {};
    for (var result in _pendingResults) {
      final courseId = result['courseId'];
      if (!resultsByCourse.containsKey(courseId)) {
        resultsByCourse[courseId] = [];
      }
      resultsByCourse[courseId]!.add(result);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: resultsByCourse.length,
      itemBuilder: (context, index) {
        final courseId = resultsByCourse.keys.elementAt(index);
        final courseResults = resultsByCourse[courseId]!;
        final courseName = courseResults.first['courseName'];
        final courseCode = courseResults.first['courseCode'];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: ExpansionTile(
            title: Text('$courseName ($courseCode)'),
            subtitle: Text('${courseResults.length} pending results'),
            trailing: ElevatedButton(
              onPressed: () => _publishAllResultsForCourse(courseId),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Publish All'),
            ),
            children:
                courseResults.map((result) {
                  final studentId = result['studentId'];
                  final studentName =
                      result['studentName'] ?? 'Student $studentId';
                  final totalGrade =
                      (result['totalGrade'] as num?)?.toDouble() ?? 0.0;
                  final letterGrade = result['letterGrade'] ?? '-';
                  final updatedAt =
                      result['updatedAt'] != null
                          ? DateFormat(
                            'yyyy-MM-dd HH:mm',
                          ).format((result['updatedAt'] as Timestamp).toDate())
                          : 'Unknown';

                  return ListTile(
                    title: Text(studentName),
                    subtitle: Text(
                      'Grade: $totalGrade - Letter: $letterGrade - Updated: $updatedAt',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      onPressed: () => _publishResult(result['id']),
                      tooltip: 'Publish Result',
                    ),
                    onTap: () => _showResultDetails(result),
                  );
                }).toList(),
          ),
        );
      },
    );
  }

  //! هنا بنبني تاب النتايج اللي اتنشرت خلاص
  Widget _buildPublishedResultsTab() {
    if (_publishedResults.isEmpty) {
      return const Center(child: Text('No published results'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _publishedResults.length,
      itemBuilder: (context, index) {
        final result = _publishedResults[index];
        final studentId = result['studentId'];
        final studentName = result['studentName'] ?? 'Student $studentId';
        final courseName = result['courseName'];
        final courseCode = result['courseCode'];
        final totalGrade = (result['totalGrade'] as num?)?.toDouble() ?? 0.0;
        final letterGrade = result['letterGrade'] ?? '-';
        final publishedAt =
            result['publishedAt'] != null
                ? DateFormat(
                  'yyyy-MM-dd HH:mm',
                ).format((result['publishedAt'] as Timestamp).toDate())
                : 'Unknown';

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
          child: ListTile(
            title: Text('$studentName - $courseName ($courseCode)'),
            subtitle: Text(
              'Grade: $totalGrade - Letter: $letterGrade - Published: $publishedAt',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.cancel, color: Colors.red),
              onPressed: () => _unpublishResult(result['id']),
              tooltip: 'Unpublish Result',
            ),
            onTap: () => _showResultDetails(result),
          ),
        );
      },
    );
  }

  //! دي الفنكشن اللي بتعرض تفاصيل النتيجة لما ندوس عليها
  void _showResultDetails(Map<String, dynamic> result) {
    final studentId = result['studentId'];
    final studentName = result['studentName'] ?? 'Student $studentId';
    final courseName = result['courseName'];
    final courseCode = result['courseCode'];
    final midtermGrade = (result['midtermGrade'] as num?)?.toDouble() ?? 0.0;
    final finalGrade = (result['finalGrade'] as num?)?.toDouble() ?? 0.0;
    final assignmentsGrade =
        (result['assignmentsGrade'] as num?)?.toDouble() ?? 0.0;
    final totalGrade = (result['totalGrade'] as num?)?.toDouble() ?? 0.0;
    final letterGrade = result['letterGrade'] ?? '-';
    final instructorName = result['instructorName'] ?? 'Unknown';
    final updatedAt =
        result['updatedAt'] != null
            ? DateFormat(
              'yyyy-MM-dd HH:mm',
            ).format((result['updatedAt'] as Timestamp).toDate())
            : 'Unknown';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Result Details for $courseName'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Student: $studentName (ID: $studentId)'),
                  const Divider(),
                  Text('Course: $courseName ($courseCode)'),
                  const Divider(),
                  Text('Midterm Grade: $midtermGrade / 20'),
                  Text('Final Exam: $finalGrade / 50'),
                  Text('Coursework: $assignmentsGrade / 30'),
                  Text('Total Grade: $totalGrade / 100'),
                  Text('Letter Grade: $letterGrade'),
                  const Divider(),
                  Text('Instructor: $instructorName'),
                  Text('Last Updated: $updatedAt'),
                  if (result['isPublished'] == true &&
                      result['publishedAt'] != null)
                    Text(
                      'Published Date: ${DateFormat('yyyy-MM-dd HH:mm').format((result['publishedAt'] as Timestamp).toDate())}',
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              if (result['isPublished'] != true)
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _publishResult(result['id']);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Publish Result'),
                ),
              if (result['isPublished'] == true)
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _unpublishResult(result['id']);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Unpublish Result'),
                ),
            ],
          ),
    );
  }
}

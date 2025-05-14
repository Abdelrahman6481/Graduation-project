import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';

class GradeEntryForm extends StatefulWidget {
  final Map<String, dynamic> course;
  final Map<String, dynamic>? instructor;

  const GradeEntryForm({super.key, required this.course, this.instructor});

  @override
  State<GradeEntryForm> createState() => _GradeEntryFormState();
}

class _GradeEntryFormState extends State<GradeEntryForm> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _students = [];
  int? _selectedStudentId;
  String _selectedSemester = 'Fall';
  final int _currentYear = DateTime.now().year;

  //! دي الكنترولرز اللي هنستخدمها عشان ندخل الدرجات
  final TextEditingController _midtermController = TextEditingController();
  final TextEditingController _finalController = TextEditingController();
  final TextEditingController _courseworkController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  //! دي أقصى درجة ممكن الطالب ياخدها في كل جزء
  final double _maxMidterm = 20.0;
  final double _maxFinal = 50.0;
  final double _maxCoursework = 30.0;

  //! دي الدرجات اللي هيدخلها المدرس للطالب
  double _midtermGrade = 0.0;
  double _finalGrade = 0.0;
  double _courseworkGrade = 0.0;
  double _totalGrade = 0.0;
  String _letterGrade = 'F';

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  @override
  void dispose() {
    _midtermController.dispose();
    _finalController.dispose();
    _courseworkController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final courseId = int.tryParse(widget.course['id'].toString()) ?? 0;
      final students = await _firestoreService.getStudentsInCourse(courseId);

      setState(() {
        _students = students;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading students: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _calculateGrades() {
    //! هنحول القيم اللي دخلها المدرس من نص لأرقام
    _midtermGrade = double.tryParse(_midtermController.text) ?? 0.0;
    _finalGrade = double.tryParse(_finalController.text) ?? 0.0;
    _courseworkGrade = double.tryParse(_courseworkController.text) ?? 0.0;

    //! هنتأكد إن الدرجات مش أكبر من الحد الأقصى
    _midtermGrade = _midtermGrade.clamp(0, _maxMidterm);
    _finalGrade = _finalGrade.clamp(0, _maxFinal);
    _courseworkGrade = _courseworkGrade.clamp(0, _maxCoursework);

    //! هنحسب الدرجة الكلية للطالب
    _totalGrade = _midtermGrade + _finalGrade + _courseworkGrade;

    //! هنحدد التقدير بتاع الطالب (A, B, C, ...)
    if (_totalGrade >= 90) {
      _letterGrade = 'A';
    } else if (_totalGrade >= 80) {
      _letterGrade = 'B';
    } else if (_totalGrade >= 70) {
      _letterGrade = 'C';
    } else if (_totalGrade >= 60) {
      _letterGrade = 'D';
    } else {
      _letterGrade = 'F';
    }

    setState(() {});
  }

  //! هنحفظ الدرجات في الفايرستور عشان الأدمن يراجعها
  Future<void> _saveGrades() async {
    if (_selectedStudentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a student'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final courseId = int.tryParse(widget.course['id'].toString()) ?? 0;

      await _firestoreService.recordStudentResult(
        studentId: _selectedStudentId!,
        courseId: courseId,
        midtermGrade: _midtermGrade,
        finalGrade: _finalGrade,
        assignmentsGrade: _courseworkGrade,
        participationGrade: 0.0, //! Not used in this form
        notes: _notesController.text,
        instructorId: widget.instructor?['id']?.toString() ?? '',
        instructorName: widget.instructor?['name']?.toString() ?? '',
        semester: _selectedSemester,
        academicYear: _currentYear,
      );

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Grades saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        //! هنعمل ريسيت للفورم بعد ما نحفظ الدرجات
        _midtermController.clear();
        _finalController.clear();
        _courseworkController.clear();
        _notesController.clear();
        _selectedStudentId = null;
        _totalGrade = 0.0;
        _letterGrade = 'F';
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving grades: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildStudentSelector() {
    if (_students.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No students enrolled in this course'),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Student',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              hint: const Text('Select a student'),
              value: _selectedStudentId,
              items:
                  _students.map((student) {
                    return DropdownMenuItem<int>(
                      value: int.tryParse(student['id'].toString()) ?? 0,
                      child: Text('${student['name']} (ID: ${student['id']})'),
                    );
                  }).toList(),
              onChanged: (value) async {
                setState(() {
                  _selectedStudentId = value;

                  //! هنعمل ريسيت للدرجات لما نغير الطالب
                  _midtermController.clear();
                  _finalController.clear();
                  _courseworkController.clear();
                  _notesController.clear();
                  _totalGrade = 0.0;
                  _letterGrade = 'F';
                });

                //! هنشوف لو الطالب ده عنده درجات قبل كده في المادة دي
                if (value != null) {
                  try {
                    final courseId =
                        int.tryParse(widget.course['id'].toString()) ?? 0;
                    final existingResult = await _firestoreService
                        .getStudentResult(value, courseId);

                    if (existingResult != null) {
                      //! هنملي الفورم بالدرجات الموجودة من قبل
                      setState(() {
                        _midtermController.text =
                            existingResult['midtermGrade']?.toString() ?? '0';
                        _finalController.text =
                            existingResult['finalGrade']?.toString() ?? '0';
                        _courseworkController.text =
                            existingResult['assignmentsGrade']?.toString() ??
                            '0';
                        _notesController.text = existingResult['notes'] ?? '';
                        _selectedSemester =
                            existingResult['semester'] ?? 'Fall';

                        //! هنحسب المجموع الكلي للدرجات
                        _calculateGrades();
                      });

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Loaded existing grades for this student',
                            ),
                            backgroundColor: Colors.blue,
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    //! هنتجاهل الإيرور هنا عشان مش مهم للمستخدم
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSemesterSelector() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Semester Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Semester',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedSemester,
                    items: const [
                      DropdownMenuItem(value: 'Fall', child: Text('Fall')),
                      DropdownMenuItem(value: 'Spring', child: Text('Spring')),
                      DropdownMenuItem(value: 'Summer', child: Text('Summer')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedSemester = value;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Academic Year',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _currentYear.toString(),
                    readOnly: true,
                    enabled: false,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeForm() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Grade Components',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Midterm Grade
            TextFormField(
              controller: _midtermController,
              decoration: InputDecoration(
                labelText: 'Midterm Grade (max: $_maxMidterm)',
                border: const OutlineInputBorder(),
                suffixText: 'out of $_maxMidterm',
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => _calculateGrades(),
            ),
            const SizedBox(height: 16),

            // Final Grade
            TextFormField(
              controller: _finalController,
              decoration: InputDecoration(
                labelText: 'Final Exam Grade (max: $_maxFinal)',
                border: const OutlineInputBorder(),
                suffixText: 'out of $_maxFinal',
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => _calculateGrades(),
            ),
            const SizedBox(height: 16),

            // Coursework Grade
            TextFormField(
              controller: _courseworkController,
              decoration: InputDecoration(
                labelText: 'Total Coursework Grade (max: $_maxCoursework)',
                border: const OutlineInputBorder(),
                suffixText: 'out of $_maxCoursework',
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => _calculateGrades(),
            ),
            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeSummary() {
    Color gradeColor;

    switch (_letterGrade) {
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
      elevation: 2,
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Grade Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Grade:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_totalGrade.toStringAsFixed(1)}/100',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Letter Grade:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: gradeColor.withAlpha(50),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: gradeColor),
                  ),
                  child: Text(
                    _letterGrade,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: gradeColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _totalGrade / 100,
              backgroundColor: Colors.grey.shade300,
              color: gradeColor,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade900,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: _selectedStudentId == null ? null : _saveGrades,
        child: const Text(
          'Save Grades',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grade Entry - ${widget.course['name']}'),
        backgroundColor: Colors.red.shade900,
        foregroundColor: Colors.white,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStudentSelector(),
                    const SizedBox(height: 24),
                    _buildSemesterSelector(),
                    const SizedBox(height: 24),
                    _buildGradeForm(),
                    const SizedBox(height: 24),
                    _buildGradeSummary(),
                    const SizedBox(height: 24),
                    _buildSaveButton(),
                  ],
                ),
              ),
    );
  }
}

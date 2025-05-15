import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
// استيراد firestore_models.dart تم إزالته لأنه غير مستخدم
import 'admin_support_tickets.dart';
import 'admin_finance.dart';

class AdminHomePage extends StatefulWidget {
  final Map<String, dynamic> admin;
  const AdminHomePage({super.key, required this.admin});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage>
    with SingleTickerProviderStateMixin {
  // دالة مساعدة لعرض رسائل Snackbar بطريقة آمنة
  void _showSnackBar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : null,
        ),
      );
    }
  }

  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _courses = [];
  List<Map<String, dynamic>> _announcements = [];
  List<Map<String, dynamic>> _instructors = [];
  bool _isLoading = false;

  // Form controllers for adding a new student
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _levelController = TextEditingController();
  final _creditsController = TextEditingController();
  final _collegeNameController = TextEditingController();
  final _majorController = TextEditingController();
  final _gpaController = TextEditingController();

  // Add instructor-related controllers
  final _instructorIdController = TextEditingController();
  final _instructorNameController = TextEditingController();
  final _instructorEmailController = TextEditingController();
  final _instructorPasswordController = TextEditingController();
  final _instructorPhoneController = TextEditingController();
  final _instructorAddressController = TextEditingController();
  final _instructorDegreeController = TextEditingController();
  List<String> _selectedCourseIds = [];

  // Add course-related controllers
  final _courseIdController = TextEditingController();
  final _courseNameController = TextEditingController();
  final _courseCodeController = TextEditingController();
  final _courseCreditsController = TextEditingController();
  final _courseInstructorController = TextEditingController();
  final _courseDescriptionController = TextEditingController();
  String _selectedInstructorId = '';

  // Add announcement-related controllers
  final _announcementTitleController = TextEditingController();
  final _announcementContentController = TextEditingController();
  final _announcementCategoryController = TextEditingController();
  bool _isAnnouncementUrgent = false;
  String _selectedAnnouncementCategory = 'General';
  final List<String> _announcementCategories = [
    'General',
    'Exams',
    'Events',
    'Projects',
    'Deadlines',
  ];

  // Add lecture-related variables
  final List<Map<String, TextEditingController>> _lectureControllers = [];
  final List<String> _weekDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  String _selectedDay = 'Monday';

  // Add pending grades variable
  List<Map<String, dynamic>> _pendingGrades = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 9, vsync: this);
    _loadStudents();
    _loadCourses();
    _loadAnnouncements();
    _loadInstructors().then((_) {
      // Set default instructor if available
      if (_instructors.isNotEmpty) {
        setState(() {
          _selectedInstructorId = _instructors[0]['id'].toString();
          _courseInstructorController.text = _instructors[0]['name'] ?? '';
        });
      }
    });
    _loadPendingGrades();
    // Add an initial empty lecture row
    _addLectureRow();
  }

  // Add a function to load pending grades
  Future<void> _loadPendingGrades() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collection('grades')
              .where('status', isEqualTo: 'pending')
              .get();

      final List<Map<String, dynamic>> loadedGrades = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        loadedGrades.add({'id': doc.id, ...data});
      }

      setState(() {
        _pendingGrades = loadedGrades;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        _showSnackBar('Error loading pending grades: $e', isError: true);
      }
    }
  }

  Future<void> _approveGrade(String gradeId) async {
    try {
      await FirebaseFirestore.instance.collection('grades').doc(gradeId).update(
        {'status': 'approved'},
      );

      _showSnackBar('Grade approved successfully!');

      // Reload pending grades
      await _loadPendingGrades();
    } catch (e) {
      _showSnackBar('Error approving grade: $e', isError: true);
    }
  }

  Future<void> _rejectGrade(String gradeId) async {
    try {
      await FirebaseFirestore.instance.collection('grades').doc(gradeId).update(
        {'status': 'rejected'},
      );

      _showSnackBar('Grade rejected successfully!');

      // Reload pending grades
      await _loadPendingGrades();
    } catch (e) {
      _showSnackBar('Error rejecting grade: $e', isError: true);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _idController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _levelController.dispose();
    _creditsController.dispose();
    _collegeNameController.dispose();
    _majorController.dispose();
    _gpaController.dispose();

    // Dispose instructor controllers
    _instructorIdController.dispose();
    _instructorNameController.dispose();
    _instructorEmailController.dispose();
    _instructorPasswordController.dispose();
    _instructorPhoneController.dispose();
    _instructorAddressController.dispose();
    _instructorDegreeController.dispose();

    // Dispose course controllers
    _courseIdController.dispose();
    _courseNameController.dispose();
    _courseCodeController.dispose();
    _courseCreditsController.dispose();
    _courseInstructorController.dispose();
    _courseDescriptionController.dispose();

    // Dispose announcement controllers
    _announcementTitleController.dispose();
    _announcementContentController.dispose();
    _announcementCategoryController.dispose();

    // Dispose lecture controllers
    for (var controllers in _lectureControllers) {
      controllers['time']?.dispose();
      controllers['room']?.dispose();
    }

    super.dispose();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('students').get();
      final List<Map<String, dynamic>> loadedStudents = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        loadedStudents.add({'id': doc.id, ...data});
      }

      setState(() {
        _students = loadedStudents;
        _isLoading = false;
      });

      if (kDebugMode) {
        debugPrint('Loaded ${loadedStudents.length} students');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading students: $e')));
      }
    }
  }

  Future<void> _loadCourses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('courses').get();
      final List<Map<String, dynamic>> loadedCourses = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        loadedCourses.add({'id': doc.id, ...data});
      }

      setState(() {
        _courses = loadedCourses;
        _isLoading = false;
      });
    } catch (e) {
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

  Future<void> _loadAnnouncements() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collection('announcements')
              .orderBy('date', descending: true)
              .get();
      final List<Map<String, dynamic>> loadedAnnouncements = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        // Convert Timestamp to DateTime if needed
        final date =
            data['date'] is Timestamp
                ? (data['date'] as Timestamp).toDate()
                : DateTime.now();

        loadedAnnouncements.add({'id': doc.id, ...data, 'date': date});
      }

      setState(() {
        _announcements = loadedAnnouncements;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading announcements: $e')),
        );
      }
    }
  }

  Future<void> _loadInstructors() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('instructors').get();
      final List<Map<String, dynamic>> loadedInstructors = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        loadedInstructors.add({'id': doc.id, ...data});
      }

      setState(() {
        _instructors = loadedInstructors;
        _isLoading = false;
      });

      if (kDebugMode) {
        debugPrint('Loaded ${loadedInstructors.length} instructors');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading instructors: $e')),
        );
      }
    }
  }

  Future<void> _addStudent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final firestoreService = FirestoreService();
      await firestoreService.addNewStudent(
        id: int.parse(_idController.text),
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        phone:
            _phoneController
                .text, // This now contains the complete number with country code
        address: _addressController.text,
        level: int.parse(_levelController.text),
        credits: int.parse(_creditsController.text),
        collegeName: _collegeNameController.text,
        major: _majorController.text,
        gpa: double.parse(_gpaController.text),
      );

      _showSnackBar('Student added successfully!');

      // Clear the form
      _idController.clear();
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _phoneController.clear();
      _addressController.clear();
      _levelController.clear();
      _creditsController.clear();
      _collegeNameController.clear();
      _majorController.clear();
      _gpaController.clear();

      // Refresh the student list
      await _loadStudents();
    } catch (e) {
      _showSnackBar('Error adding student: $e', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleBanStudent(String studentId, bool currentStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('students')
          .doc(studentId)
          .update({'isBanned': !currentStatus});

      _showSnackBar(
        currentStatus
            ? 'Student unbanned successfully!'
            : 'Student banned successfully!',
      );

      // Refresh the student list
      await _loadStudents();
    } catch (e) {
      _showSnackBar('Error updating student status: $e', isError: true);
    }
  }

  Future<void> _addStringIdAdmin(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('admins')
          .doc('m81l0WRZ8eaySsaoY83AaGlNh733')
          .set({
            'id': 'm81l0WRZ8eaySsaoY83AaGlNh733',
            'name': 'String ID Admin',
            'email': 'stringidadmin@example.com',
            'password': 'adminpassword',
            'phone': '0123456789',
            'address': 'Admin HQ',
            'lastLogin': FieldValue.serverTimestamp(),
          });
      _showSnackBar('Admin m81l0WRZ8eaySsaoY83AaGlNh733 added!');
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}', isError: true);
    }
  }

  Future<void> _addCourse() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final courseId = int.parse(_courseIdController.text);
      final courseName = _courseNameController.text;
      final courseCode = _courseCodeController.text;
      final courseCredits = int.parse(_courseCreditsController.text);
      final instructorName = _courseInstructorController.text;
      final instructorId = _selectedInstructorId;
      final description = _courseDescriptionController.text;

      // Create lectures list from controllers
      final List<Map<String, dynamic>> lectures = [];
      for (var controller in _lectureControllers) {
        if ((controller['room']?.text.isNotEmpty ?? false) &&
            (controller['time']?.text.isNotEmpty ?? false)) {
          lectures.add({
            'day': controller['day']?.text ?? _selectedDay,
            'time': controller['time']?.text,
            'room': controller['room']?.text,
          });
        }
      }

      // Create course object
      final course = {
        'id': courseId,
        'name': courseName,
        'code': courseCode,
        'credits': courseCredits,
        'instructor': instructorName,
        'instructorId': instructorId, // Store the instructor ID for reference
        'description': description,
        'isActive': true,
        'lectures': lectures,
      };

      // Add to Firestore
      await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId.toString())
          .set(course);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course added successfully!')),
      );

      // Clear the form
      _courseIdController.clear();
      _courseNameController.clear();
      _courseCodeController.clear();
      _courseCreditsController.clear();
      _courseInstructorController.clear();
      _courseDescriptionController.clear();

      // Reset instructor selection if instructors are available
      setState(() {
        if (_instructors.isNotEmpty) {
          _selectedInstructorId = _instructors[0]['id'].toString();
          _courseInstructorController.text = _instructors[0]['name'] ?? '';
        } else {
          _selectedInstructorId = '';
        }
      });

      // Clear lecture controllers and add one empty row
      for (var controllers in _lectureControllers) {
        controllers['time']?.dispose();
        controllers['room']?.dispose();
      }
      _lectureControllers.clear();
      _addLectureRow();

      // Refresh the course list
      await _loadCourses();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error adding course: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _removeCourse(String courseId) async {
    try {
      await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course removed successfully!')),
      );

      // Refresh the course list
      await _loadCourses();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error removing course: $e')));
    }
  }

  Future<void> _addAnnouncement() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final announcement = {
        'title': _announcementTitleController.text,
        'content': _announcementContentController.text,
        'category': _selectedAnnouncementCategory,
        'date': FieldValue.serverTimestamp(),
        'isUrgent': _isAnnouncementUrgent,
      };

      await FirebaseFirestore.instance
          .collection('announcements')
          .add(announcement);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Announcement added successfully!')),
      );

      // Clear the form
      _announcementTitleController.clear();
      _announcementContentController.clear();
      _isAnnouncementUrgent = false;
      _selectedAnnouncementCategory = 'General';

      // Refresh the announcements list
      await _loadAnnouncements();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error adding announcement: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _removeAnnouncement(String announcementId) async {
    try {
      await FirebaseFirestore.instance
          .collection('announcements')
          .doc(announcementId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Announcement removed successfully!')),
      );

      // Refresh the announcements list
      await _loadAnnouncements();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing announcement: $e')),
      );
    }
  }

  Future<void> _deleteStudent(String studentId) async {
    try {
      final firestoreService = FirestoreService();
      await firestoreService.deleteStudent(studentId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student deleted successfully!')),
      );

      // Refresh the student list
      await _loadStudents();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting student: $e')));
    }
  }

  void _showDeleteStudentDialog(Map<String, dynamic> student) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Student'),
            content: Text(
              'Are you sure you want to delete "${student['name']}"?\n\nThis will permanently remove the student and all their data including course registrations, attendance records, and submissions. This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteStudent(student['id']);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.red.shade900,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/prelogin');
            },
            tooltip: 'Logout from admin account',
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
            Tab(text: 'Add Student', icon: Icon(Icons.person_add)),
            Tab(text: 'Manage Students', icon: Icon(Icons.people)),
            Tab(text: 'Manage Courses', icon: Icon(Icons.book)),
            Tab(text: 'Announcements', icon: Icon(Icons.announcement)),
            Tab(text: 'Instructors', icon: Icon(Icons.school)),
            Tab(text: 'Support Tickets', icon: Icon(Icons.support)),
            Tab(text: 'Finance', icon: Icon(Icons.payments_outlined)),
            Tab(text: 'Pending Grades', icon: Icon(Icons.pending_actions)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Overview
          _buildOverviewTab(),

          // Tab 2: Add Student Form
          _buildAddStudentTab(),

          // Tab 3: Manage Students (Ban/Unban)
          _buildManageStudentsTab(),

          // Tab 4: Manage Courses
          _buildCoursesTab(),

          // Tab 5: Manage Announcements
          _buildAnnouncementsTab(),

          // Tab 6: Manage Instructors
          _buildInstructorsTab(),

          // Tab 7: Support Tickets
          const AdminSupportTicketsPage(),

          // Tab 8: Finance
          _buildFinanceTab(),

          // Tab 9: Pending Grades
          _buildPendingGradesTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, ${widget.admin['name'] ?? 'Admin'}!',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(
                Icons.admin_panel_settings,
                color: Colors.red,
              ),
              title: Text('ID: ${widget.admin['id'] ?? ''}'),
              subtitle: Text('Email: ${widget.admin['email'] ?? ''}'),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Icon(Icons.people, size: 40, color: Colors.blue),
                        const SizedBox(height: 8),
                        const Text(
                          'Total Students',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_students.length}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Icon(Icons.block, size: 40, color: Colors.red),
                        const SizedBox(height: 8),
                        const Text(
                          'Banned Students',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_students.where((s) => s['isBanned'] == true).length}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => _addStringIdAdmin(context),
            child: const Text(
              'Add Special Admin (ID: m81l0WRZ8eaySsaoY83AaGlNh733)',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddStudentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add New Student',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // ID Field
            TextFormField(
              controller: _idController,
              decoration: const InputDecoration(
                labelText: 'Student ID (numeric)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter student ID';
                }
                if (int.tryParse(value) == null) {
                  return 'ID must be a number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Name Field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter student name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Email Field
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Password Field
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Phone Field with Country Code
            IntlPhoneField(
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
              initialCountryCode: 'EG',
              disableLengthCheck: false,
              onChanged: (phone) {
                // Store the complete number in the controller when form is submitted
                _phoneController.text = phone.completeNumber;
              },
              invalidNumberMessage: 'Invalid phone number',
            ),
            const SizedBox(height: 16),

            // Address Field
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Level Field (Dropdown)
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Level',
                border: OutlineInputBorder(),
              ),
              value:
                  _levelController.text.isEmpty ? null : _levelController.text,
              hint: const Text('Select student level'),
              items:
                  ['1', '2', '3', '4'].map((String level) {
                    return DropdownMenuItem<String>(
                      value: level,
                      child: Text('Level $level'),
                    );
                  }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _levelController.text = newValue ?? '';
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a level';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Credits Field
            TextFormField(
              controller: _creditsController,
              decoration: const InputDecoration(
                labelText: 'Credits',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter credits';
                }
                if (int.tryParse(value) == null) {
                  return 'Credits must be a number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // College Name Field
            TextFormField(
              controller: _collegeNameController,
              decoration: const InputDecoration(
                labelText: 'College Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter college name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Major Field
            TextFormField(
              controller: _majorController,
              decoration: const InputDecoration(
                labelText: 'Major',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter major';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // GPA Field
            TextFormField(
              controller: _gpaController,
              decoration: const InputDecoration(
                labelText: 'GPA (0.0-4.0)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter GPA';
                }
                final gpa = double.tryParse(value);
                if (gpa == null) {
                  return 'GPA must be a number';
                }
                if (gpa < 0 || gpa > 4) {
                  return 'GPA must be between 0 and 4';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _addStudent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade900,
                  foregroundColor: Colors.white,
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          'Add Student',
                          style: TextStyle(fontSize: 16),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManageStudentsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_students.isEmpty) {
      return const Center(child: Text('No students found'));
    }

    return RefreshIndicator(
      onRefresh: _loadStudents,
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _students.length,
        itemBuilder: (context, index) {
          final student = _students[index];
          final isBanned = student['isBanned'] == true;

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey.shade200,
                child: Text(
                  student['name']?.substring(0, 1).toUpperCase() ?? 'S',
                  style: TextStyle(color: Colors.red.shade900),
                ),
              ),
              title: Text(student['name'] ?? 'Unknown'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ID: ${student['id']}'),
                  Text('Email: ${student['email']}'),
                  Text('Major: ${student['major']}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isBanned)
                    const Chip(
                      label: Text(
                        'BANNED',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  IconButton(
                    icon: Icon(
                      isBanned ? Icons.check_circle : Icons.block,
                      color: isBanned ? Colors.green : Colors.red,
                    ),
                    onPressed: () => _toggleBanStudent(student['id'], isBanned),
                    tooltip: isBanned ? 'Unban Student' : 'Ban Student',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteStudentDialog(student),
                    tooltip: 'Delete Student',
                  ),
                ],
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }

  Widget _buildCoursesTab() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // Inner tab bar for Courses
          TabBar(
            labelColor: Colors.red.shade900,
            tabs: const [Tab(text: 'All Courses'), Tab(text: 'Add Course')],
          ),

          // Inner tab views
          Expanded(
            child: TabBarView(
              children: [
                // All Courses View
                _buildCoursesList(),

                // Add Course Form
                _buildAddCourseForm(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_courses.isEmpty) {
      return const Center(child: Text('No courses found'));
    }

    return RefreshIndicator(
      onRefresh: _loadCourses,
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _courses.length,
        itemBuilder: (context, index) {
          final course = _courses[index];
          final lectures = course['lectures'] as List<dynamic>? ?? [];

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: Colors.red.shade900,
                foregroundColor: Colors.white,
                child: Text(
                  course['code']?.substring(0, 2).toUpperCase() ?? 'C',
                ),
              ),
              title: Text(course['name'] ?? 'Unknown'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Code: ${course['code']}'),
                  Text('Credits: ${course['credits']}'),
                  Text('Instructor: ${course['instructor']}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.person_add, color: Colors.blue),
                    onPressed: () => _showAssignCourseDialog(course),
                    tooltip: 'Assign to Student',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showRemoveCourseDialog(course),
                    tooltip: 'Remove Course',
                  ),
                ],
              ),
              children: [
                if (lectures.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No lectures scheduled yet'),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: lectures.length,
                    itemBuilder: (context, lectureIndex) {
                      final lecture = lectures[lectureIndex];
                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.calendar_today),
                        title: Text('${lecture['day']} - ${lecture['time']}'),
                        subtitle: Text('Room: ${lecture['room']}'),
                      );
                    },
                  ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.edit_calendar),
                    label: const Text('Manage Lectures'),
                    onPressed: () => _showManageLecturesDialog(course),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddCourseForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add New Course',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Course ID Field
            TextFormField(
              controller: _courseIdController,
              decoration: const InputDecoration(
                labelText: 'Course ID (numeric)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter course ID';
                }
                if (int.tryParse(value) == null) {
                  return 'ID must be a number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Course Name Field
            TextFormField(
              controller: _courseNameController,
              decoration: const InputDecoration(
                labelText: 'Course Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter course name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Course Code Field
            TextFormField(
              controller: _courseCodeController,
              decoration: const InputDecoration(
                labelText: 'Course Code (e.g., CS101)',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter course code';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Credits Field
            TextFormField(
              controller: _courseCreditsController,
              decoration: const InputDecoration(
                labelText: 'Credits',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter credits';
                }
                if (int.tryParse(value) == null) {
                  return 'Credits must be a number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Instructor Field
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Instructor',
                border: OutlineInputBorder(),
              ),
              value: _instructors.isNotEmpty ? _selectedInstructorId : null,
              hint: const Text('Select an instructor'),
              items:
                  _instructors.map((instructor) {
                    return DropdownMenuItem<String>(
                      value: instructor['id'].toString(),
                      child: Text(
                        '${instructor['name']} (${instructor['academicDegree'] ?? 'Instructor'})',
                      ),
                    );
                  }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedInstructorId = newValue ?? '';
                  // Get instructor name for display purposes
                  if (newValue != null) {
                    final selectedInstructor = _instructors.firstWhere(
                      (instructor) => instructor['id'].toString() == newValue,
                      orElse: () => {'name': ''},
                    );
                    _courseInstructorController.text =
                        selectedInstructor['name'] ?? '';
                  }
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select an instructor';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description Field
            TextFormField(
              controller: _courseDescriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter course description';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Lectures Section
            const Text(
              'Lectures',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add one or more lectures for this course (optional)',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // Lecture rows
            ...List.generate(_lectureControllers.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  children: [
                    // Day dropdown
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Day',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedDay,
                        items:
                            _weekDays.map((String day) {
                              return DropdownMenuItem<String>(
                                value: day,
                                child: Text(day),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedDay = newValue!;
                            _lectureControllers[index]['day']?.text = newValue;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Time field
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _lectureControllers[index]['time'],
                        decoration: const InputDecoration(
                          labelText: 'Time',
                          hintText: '9:00-10:30',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Room field
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _lectureControllers[index]['room'],
                        decoration: const InputDecoration(
                          labelText: 'Room',
                          hintText: 'A101',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        if (_lectureControllers.length > 1) {
                          _removeLectureRow(index);
                        } else {
                          // Clear the fields instead of removing the only row
                          _lectureControllers[index]['time']?.clear();
                          _lectureControllers[index]['room']?.clear();
                        }
                      },
                    ),
                  ],
                ),
              );
            }),

            Center(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Another Lecture'),
                onPressed: _addLectureRow,
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _addCourse,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade900,
                  foregroundColor: Colors.white,
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          'Add Course',
                          style: TextStyle(fontSize: 16),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRemoveCourseDialog(Map<String, dynamic> course) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Remove Course'),
            content: Text(
              'Are you sure you want to remove "${course['name']}"? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _removeCourse(course['id'].toString());
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Remove'),
              ),
            ],
          ),
    );
  }

  // Method to add a new lecture row
  void _addLectureRow() {
    setState(() {
      _lectureControllers.add({
        'day': TextEditingController(text: _selectedDay),
        'time': TextEditingController(),
        'room': TextEditingController(),
      });
    });
  }

  // Method to remove a lecture row
  void _removeLectureRow(int index) {
    setState(() {
      var controllers = _lectureControllers.removeAt(index);
      controllers['time']?.dispose();
      controllers['room']?.dispose();
    });
  }

  Widget _buildLecturesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add Course Lectures',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Configure lecture schedule for courses',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Course selection dropdown
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Select Course',
              border: OutlineInputBorder(),
            ),
            items:
                _courses.map((course) {
                  return DropdownMenuItem<String>(
                    value: course['id'].toString(),
                    child: Text('${course['code']} - ${course['name']}'),
                  );
                }).toList(),
            onChanged: (String? courseId) {
              if (courseId != null) {
                final course = _courses.firstWhere(
                  (c) => c['id'].toString() == courseId,
                  orElse: () => {},
                );
                _showManageLecturesDialog(course);
              }
            },
          ),

          const SizedBox(height: 32),
          const Center(
            child: Text(
              'Select a course from the dropdown to manage its lectures',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewCoursesTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_courses.isEmpty) {
      return const Center(child: Text('No courses found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _courses.length,
      itemBuilder: (context, index) {
        final course = _courses[index];
        final isActive = course['isActive'] == true;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      course['name'] ?? 'Unnamed Course',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.green[100] : Colors.red[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          color: isActive ? Colors.green[800] : Colors.red[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Course Code: ${course['code'] ?? 'No Code'}',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'Credits: ${course['credits'] ?? '0'}',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'Instructor: ${course['instructor'] ?? 'No Instructor'}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Description: ${course['description'] ?? 'No description available'}',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                if (course['lectures'] != null &&
                    (course['lectures'] as List).isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      const Text(
                        'Lecture Schedule:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...(course['lectures'] as List).map((lecture) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '${lecture['day'] ?? 'Day'}: ${lecture['time'] ?? 'Time'} @ ${lecture['room'] ?? 'Room'}',
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () async {
                        // Toggle active status
                        await FirebaseFirestore.instance
                            .collection('courses')
                            .doc(course['id'].toString())
                            .update({'isActive': !isActive});

                        // Refresh courses
                        _loadCourses();
                      },
                      child: Text(isActive ? 'Deactivate' : 'Activate'),
                    ),
                    TextButton(
                      onPressed: () => _removeCourse(course['id'].toString()),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Remove'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFinanceTab() {
    return const AdminFinancePage();
  }

  void _showManageLecturesDialog(Map<String, dynamic> course) {
    // Create a temporary list of lecture controllers for this dialog
    final List<Map<String, TextEditingController>> tempLectureControllers = [];

    // Initialize with existing lectures if any
    final lectures = course['lectures'] as List<dynamic>? ?? [];
    if (lectures.isNotEmpty) {
      for (var lecture in lectures) {
        tempLectureControllers.add({
          'day': TextEditingController(text: lecture['day'] ?? ''),
          'time': TextEditingController(text: lecture['time'] ?? ''),
          'room': TextEditingController(text: lecture['room'] ?? ''),
        });
      }
    } else {
      // Add at least one empty lecture row
      tempLectureControllers.add({
        'day': TextEditingController(text: _selectedDay),
        'time': TextEditingController(),
        'room': TextEditingController(),
      });
    }

    // Track selected day for each lecture
    final List<String> selectedDays =
        tempLectureControllers
            .map((c) => c['day']?.text ?? _selectedDay)
            .toList();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Manage Lectures for ${course['name']}'),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Display all lecture rows
                      ...List.generate(tempLectureControllers.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Row(
                            children: [
                              // Day dropdown
                              Expanded(
                                flex: 3,
                                child: DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    labelText: 'Day',
                                    border: OutlineInputBorder(),
                                  ),
                                  value: selectedDays[index],
                                  items:
                                      _weekDays.map((String day) {
                                        return DropdownMenuItem<String>(
                                          value: day,
                                          child: Text(day),
                                        );
                                      }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedDays[index] = newValue!;
                                      tempLectureControllers[index]['day']
                                          ?.text = newValue;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Time field
                              Expanded(
                                flex: 3,
                                child: TextFormField(
                                  controller:
                                      tempLectureControllers[index]['time'],
                                  decoration: const InputDecoration(
                                    labelText: 'Time',
                                    hintText: '9:00-10:30',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Room field
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller:
                                      tempLectureControllers[index]['room'],
                                  decoration: const InputDecoration(
                                    labelText: 'Room',
                                    hintText: 'A101',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  setState(() {
                                    if (tempLectureControllers.length > 1) {
                                      tempLectureControllers.removeAt(index);
                                      selectedDays.removeAt(index);
                                    } else {
                                      // Clear the fields instead of removing the only row
                                      tempLectureControllers[index]['time']
                                          ?.clear();
                                      tempLectureControllers[index]['room']
                                          ?.clear();
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      }),

                      Center(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Add Another Lecture'),
                          onPressed: () {
                            setState(() {
                              tempLectureControllers.add({
                                'day': TextEditingController(
                                  text: _selectedDay,
                                ),
                                'time': TextEditingController(),
                                'room': TextEditingController(),
                              });
                              selectedDays.add(_selectedDay);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    // Create the updated lectures list
                    final List<Map<String, dynamic>> updatedLectures = [];
                    for (
                      var index = 0;
                      index < tempLectureControllers.length;
                      index++
                    ) {
                      var controller = tempLectureControllers[index];
                      if ((controller['room']?.text.isNotEmpty ?? false) &&
                          (controller['time']?.text.isNotEmpty ?? false)) {
                        updatedLectures.add({
                          'day': controller['day']?.text ?? selectedDays[index],
                          'time': controller['time']?.text,
                          'room': controller['room']?.text,
                        });
                      }
                    }

                    try {
                      // Update course with new lectures
                      await FirebaseFirestore.instance
                          .collection('courses')
                          .doc(course['id'].toString())
                          .update({'lectures': updatedLectures});

                      _showSnackBar('Lectures updated successfully!');

                      // Reload courses
                      await _loadCourses();
                    } catch (e) {
                      _showSnackBar(
                        'Error updating lectures: $e',
                        isError: true,
                      );
                    }

                    if (mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      // Clean up temp controllers
      for (var controller in tempLectureControllers) {
        controller['day']?.dispose();
        controller['time']?.dispose();
        controller['room']?.dispose();
      }
    });
  }

  void _showAssignCourseDialog(Map<String, dynamic> course) {
    final _selectedStudentIds = <String>[];
    final List<Map<String, dynamic>> _availableStudents = [..._students];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Assign ${course['name']} to Students'),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Select students to enroll in this course',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _availableStudents.length,
                        itemBuilder: (context, index) {
                          final student = _availableStudents[index];
                          final studentId = student['id'].toString();
                          final isSelected = _selectedStudentIds.contains(
                            studentId,
                          );

                          return CheckboxListTile(
                            title: Text(student['name'] ?? 'Unknown'),
                            subtitle: Text(
                              'ID: $studentId - Level: ${student['level'] ?? 'N/A'}',
                            ),
                            value: isSelected,
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  _selectedStudentIds.add(studentId);
                                } else {
                                  _selectedStudentIds.remove(studentId);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    if (_selectedStudentIds.isEmpty) {
                      _showSnackBar(
                        'Please select at least one student',
                        isError: true,
                      );
                      return;
                    }

                    try {
                      final batch = FirebaseFirestore.instance.batch();
                      final courseId = course['id'].toString();

                      // Add registration for each selected student
                      for (var studentId in _selectedStudentIds) {
                        final registrationId = '$studentId-$courseId';
                        batch.set(
                          FirebaseFirestore.instance
                              .collection('registrations')
                              .doc(registrationId),
                          {
                            'studentId': studentId,
                            'courseId': courseId,
                            'courseName': course['name'],
                            'courseCode': course['code'],
                            'registrationDate': FieldValue.serverTimestamp(),
                            'status': 'enrolled',
                            'grades': {
                              'midterm': null,
                              'final': null,
                              'assignments': null,
                              'total': null,
                            },
                          },
                        );
                      }

                      await batch.commit();
                      _showSnackBar(
                        'Successfully enrolled ${_selectedStudentIds.length} students in ${course['name']}',
                      );
                      Navigator.pop(context);
                    } catch (e) {
                      _showSnackBar(
                        'Error enrolling students: $e',
                        isError: true,
                      );
                    }
                  },
                  child: const Text('Enroll Selected Students'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildAnnouncementsTab() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            labelColor: Colors.red.shade900,
            tabs: const [
              Tab(text: 'All Announcements'),
              Tab(text: 'Add Announcement'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // All Announcements View
                _buildAnnouncementsList(),

                // Add Announcement Form
                _buildAddAnnouncementForm(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_announcements.isEmpty) {
      return const Center(child: Text('No announcements found'));
    }

    return RefreshIndicator(
      onRefresh: _loadAnnouncements,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _announcements.length,
        itemBuilder: (context, index) {
          final announcement = _announcements[index];
          final date = announcement['date'] as DateTime?;
          final isUrgent = announcement['isUrgent'] == true;

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side:
                  isUrgent
                      ? BorderSide(color: Colors.red.shade700, width: 2)
                      : BorderSide.none,
            ),
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
                          announcement['title'] ?? 'Untitled',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isUrgent)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'URGENT',
                            style: TextStyle(
                              color: Colors.red.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      announcement['category'] ?? 'General',
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    announcement['content'] ?? 'No content',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    date != null
                        ? 'Posted on ${DateFormat('MMM d, yyyy - h:mm a').format(date)}'
                        : 'Date not available',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.delete, size: 18),
                        label: const Text('Remove'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        onPressed:
                            () => _removeAnnouncement(announcement['id']),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddAnnouncementForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create New Announcement',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Title Field
            TextFormField(
              controller: _announcementTitleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter announcement title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Category Dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              value: _selectedAnnouncementCategory,
              items:
                  _announcementCategories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedAnnouncementCategory = newValue!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Content Field
            TextFormField(
              controller: _announcementContentController,
              decoration: const InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 8,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter announcement content';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Urgent Checkbox
            CheckboxListTile(
              title: const Text(
                'Mark as Urgent',
                style: TextStyle(fontSize: 16),
              ),
              subtitle: const Text(
                'Urgent announcements are highlighted for students',
                style: TextStyle(fontSize: 12),
              ),
              value: _isAnnouncementUrgent,
              onChanged: (bool? value) {
                setState(() {
                  _isAnnouncementUrgent = value ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: Colors.red.shade900,
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _addAnnouncement,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade900,
                  foregroundColor: Colors.white,
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          'Post Announcement',
                          style: TextStyle(fontSize: 16),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructorsTab() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            labelColor: Colors.red.shade900,
            tabs: const [
              Tab(text: 'All Instructors'),
              Tab(text: 'Add Instructor'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // All Instructors View
                _buildInstructorsList(),

                // Add Instructor Form
                _buildAddInstructorForm(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructorsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_instructors.isEmpty) {
      return const Center(child: Text('No instructors found'));
    }

    return RefreshIndicator(
      onRefresh: _loadInstructors,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _instructors.length,
        itemBuilder: (context, index) {
          final instructor = _instructors[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: Colors.red.shade900,
                foregroundColor: Colors.white,
                child: Text(
                  instructor['name']?.substring(0, 1).toUpperCase() ?? 'I',
                ),
              ),
              title: Text(instructor['name'] ?? 'Unknown'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ID: ${instructor['id']}'),
                  Text(
                    'Degree: ${instructor['academicDegree'] ?? 'Not specified'}',
                  ),
                ],
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: const Text('Contact Information'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Email: ${instructor['email'] ?? 'Not provided'}',
                            ),
                            Text(
                              'Phone: ${instructor['phone'] ?? 'Not provided'}',
                            ),
                            Text(
                              'Address: ${instructor['address'] ?? 'Not provided'}',
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      const ListTile(title: Text('Assigned Courses')),
                      FutureBuilder<QuerySnapshot>(
                        future:
                            FirebaseFirestore.instance
                                .collection('courses')
                                .where(
                                  'instructorId',
                                  isEqualTo: instructor['id'].toString(),
                                )
                                .get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }

                          final courses = snapshot.data?.docs ?? [];

                          if (courses.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                'No courses assigned to this instructor',
                              ),
                            );
                          }

                          return Column(
                            children:
                                courses.map((doc) {
                                  final courseData =
                                      doc.data() as Map<String, dynamic>;
                                  return ListTile(
                                    leading: const Icon(Icons.book),
                                    title: Text(
                                      courseData['name'] ?? 'Unknown course',
                                    ),
                                    subtitle: Text(
                                      'Code: ${courseData['code'] ?? 'No code'}',
                                    ),
                                  );
                                }).toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            icon: const Icon(Icons.delete, size: 18),
                            label: const Text('Remove Instructor'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            onPressed:
                                () => _showDeleteInstructorDialog(instructor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddInstructorForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add New Instructor',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // ID Field
            TextFormField(
              controller: _instructorIdController,
              decoration: const InputDecoration(
                labelText: 'Instructor ID (numeric)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter instructor ID';
                }
                if (int.tryParse(value) == null) {
                  return 'ID must be a number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Name Field
            TextFormField(
              controller: _instructorNameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter instructor name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Email Field
            TextFormField(
              controller: _instructorEmailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Password Field
            TextFormField(
              controller: _instructorPasswordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Phone Field with Country Code
            IntlPhoneField(
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
              initialCountryCode: 'EG',
              disableLengthCheck: false,
              onChanged: (phone) {
                _instructorPhoneController.text = phone.completeNumber;
              },
              invalidNumberMessage: 'Invalid phone number',
            ),
            const SizedBox(height: 16),

            // Address Field
            TextFormField(
              controller: _instructorAddressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Academic Degree Field
            TextFormField(
              controller: _instructorDegreeController,
              decoration: const InputDecoration(
                labelText: 'Academic Degree (e.g., Ph.D., Professor)',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter academic degree';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            const Text(
              'Assign Courses',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Course Selection
            if (_courses.isEmpty)
              const Text(
                'No courses available to assign',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              )
            else
              ..._courses.map((course) {
                return CheckboxListTile(
                  title: Text(course['name'] ?? 'Unknown course'),
                  subtitle: Text('Code: ${course['code']}'),
                  value: _selectedCourseIds.contains(course['id'].toString()),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _selectedCourseIds.add(course['id'].toString());
                      } else {
                        _selectedCourseIds.remove(course['id'].toString());
                      }
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: Colors.red.shade900,
                );
              }).toList(),

            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _addInstructor,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade900,
                  foregroundColor: Colors.white,
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          'Add Instructor',
                          style: TextStyle(fontSize: 16),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteInstructorDialog(Map<String, dynamic> instructor) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Instructor'),
            content: Text(
              'Are you sure you want to delete "${instructor['name']}"?\n\nThis will permanently remove the instructor from the system. Any courses assigned to this instructor will need to be reassigned.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteInstructor(instructor['id']);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteInstructor(String instructorId) async {
    try {
      await FirebaseFirestore.instance
          .collection('instructors')
          .doc(instructorId)
          .delete();

      _showSnackBar('Instructor deleted successfully!');

      // Reload instructors
      await _loadInstructors();
    } catch (e) {
      _showSnackBar('Error deleting instructor: $e', isError: true);
    }
  }

  Future<void> _addInstructor() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final instructorId = int.parse(_instructorIdController.text);

      // Create the instructor document
      final instructor = {
        'id': instructorId,
        'name': _instructorNameController.text,
        'email': _instructorEmailController.text,
        'password': _instructorPasswordController.text,
        'phone': _instructorPhoneController.text,
        'address': _instructorAddressController.text,
        'academicDegree': _instructorDegreeController.text,
        'courses': _selectedCourseIds,
      };

      // Add to Firestore
      await FirebaseFirestore.instance
          .collection('instructors')
          .doc(instructorId.toString())
          .set(instructor);

      // Update selected courses with this instructor
      final batch = FirebaseFirestore.instance.batch();
      for (var courseId in _selectedCourseIds) {
        batch.update(
          FirebaseFirestore.instance.collection('courses').doc(courseId),
          {
            'instructorId': instructorId.toString(),
            'instructor': _instructorNameController.text,
          },
        );
      }
      await batch.commit();

      _showSnackBar('Instructor added successfully!');

      // Clear the form
      _instructorIdController.clear();
      _instructorNameController.clear();
      _instructorEmailController.clear();
      _instructorPasswordController.clear();
      _instructorPhoneController.clear();
      _instructorAddressController.clear();
      _instructorDegreeController.clear();
      setState(() {
        _selectedCourseIds = [];
      });

      // Reload instructors and courses
      await _loadInstructors();
      await _loadCourses();
    } catch (e) {
      _showSnackBar('Error adding instructor: $e', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildPendingGradesTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_pendingGrades.isEmpty) {
      return const Center(
        child: Text(
          'No pending grades to review',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPendingGrades,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pending Grade Submissions',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Review and approve grade submissions from instructors',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _pendingGrades.length,
              itemBuilder: (context, index) {
                final grade = _pendingGrades[index];
                final courseCode = grade['courseCode'] ?? 'Unknown Course';
                final courseName = grade['courseName'] ?? '';
                final instructorName =
                    grade['instructorName'] ?? 'Unknown Instructor';
                final submissionDate =
                    grade['submissionDate'] is Timestamp
                        ? (grade['submissionDate'] as Timestamp).toDate()
                        : DateTime.now();

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ExpansionTile(
                    title: Text('$courseCode - $courseName'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Submitted by: $instructorName'),
                        Text(
                          'Date: ${DateFormat('MMM d, yyyy - h:mm a').format(submissionDate)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Student Grades',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Divider(),
                            if (grade['grades'] != null)
                              ...(_buildGradesList(grade['grades'])),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                  ),
                                  label: const Text('Reject'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  onPressed: () => _rejectGrade(grade['id']),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.check),
                                  label: const Text('Approve'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () => _approveGrade(grade['id']),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildGradesList(dynamic grades) {
    if (grades is! Map) {
      return [const Text('No grade data available')];
    }

    final widgets = <Widget>[];

    // If grades is a map of student grades
    if (grades['students'] != null && grades['students'] is List) {
      final studentGrades = grades['students'] as List;

      widgets.add(
        DataTable(
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Midterm')),
            DataColumn(label: Text('Final')),
            DataColumn(label: Text('Assignments')),
            DataColumn(label: Text('Total')),
          ],
          rows:
              studentGrades.map<DataRow>((student) {
                return DataRow(
                  cells: [
                    DataCell(Text(student['id']?.toString() ?? '')),
                    DataCell(Text(student['name'] ?? '')),
                    DataCell(Text(student['midterm']?.toString() ?? 'N/A')),
                    DataCell(Text(student['final']?.toString() ?? 'N/A')),
                    DataCell(Text(student['assignments']?.toString() ?? 'N/A')),
                    DataCell(Text(student['total']?.toString() ?? 'N/A')),
                  ],
                );
              }).toList(),
        ),
      );
    } else {
      // If it's a different format, just display the raw data
      grades.forEach((key, value) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Text(
                  '$key: ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(value?.toString() ?? 'N/A'),
              ],
            ),
          ),
        );
      });
    }

    return widgets;
  }
}

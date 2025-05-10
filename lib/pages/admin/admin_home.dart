import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../models/firestore_models.dart';
import 'admin_support_tickets.dart';

class AdminHomePage extends StatefulWidget {
  final Map<String, dynamic> admin;
  const AdminHomePage({Key? key, required this.admin}) : super(key: key);

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage>
    with SingleTickerProviderStateMixin {
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
  List<Map<String, TextEditingController>> _lectureControllers = [];
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
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
    // Add an initial empty lecture row
    _addLectureRow();
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

      print('Loaded ${loadedStudents.length} students');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading students: $e')));
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading courses: $e')));
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading announcements: $e')),
      );
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

      print('Loaded ${loadedInstructors.length} instructors');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading instructors: $e')));
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student added successfully!')),
      );

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error adding student: $e')));
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            currentStatus
                ? 'Student unbanned successfully!'
                : 'Student banned successfully!',
          ),
        ),
      );

      // Refresh the student list
      await _loadStudents();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating student status: $e')),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Admin m81l0WRZ8eaySsaoY83AaGlNh733 added!'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ' + e.toString())));
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

  Widget _buildAnnouncementsTab() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // Inner tab bar for Announcements
          TabBar(
            labelColor: Colors.red.shade900,
            tabs: const [
              Tab(text: 'All Announcements'),
              Tab(text: 'Add Announcement'),
            ],
          ),

          // Inner tab views
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
        padding: const EdgeInsets.all(8.0),
        itemCount: _announcements.length,
        itemBuilder: (context, index) {
          final announcement = _announcements[index];
          final DateTime date = announcement['date'];
          final DateFormat formatter = DateFormat('MMM d, y - h:mm a');

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side:
                  announcement['isUrgent'] == true
                      ? BorderSide(color: Colors.red.shade300, width: 1.5)
                      : BorderSide.none,
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      announcement['title'] ?? 'Unknown',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          announcement['isUrgent'] == true
                              ? Colors.red.shade50
                              : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      announcement['category'] ?? 'General',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            announcement['isUrgent'] == true
                                ? Colors.red.shade900
                                : Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    announcement['content'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formatter.format(date),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _showRemoveAnnouncementDialog(announcement),
                tooltip: 'Remove Announcement',
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }

  void _showRemoveAnnouncementDialog(Map<String, dynamic> announcement) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Remove Announcement'),
            content: Text(
              'Are you sure you want to remove "${announcement['title']}"? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _removeAnnouncement(announcement['id']);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Remove'),
              ),
            ],
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
              'Add New Announcement',
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

            // Content Field
            TextFormField(
              controller: _announcementContentController,
              decoration: const InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter announcement content';
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
                  _selectedAnnouncementCategory = newValue ?? 'General';
                });
              },
            ),
            const SizedBox(height: 16),

            // Urgent Checkbox
            CheckboxListTile(
              title: const Text('Mark as Urgent'),
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
                          'Add Announcement',
                          style: TextStyle(fontSize: 16),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAssignCourseDialog(Map<String, dynamic> course) async {
    // Implementation of _showAssignCourseDialog method
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

  // Dialog to manage lectures for an existing course
  Future<void> _showManageLecturesDialog(Map<String, dynamic> course) async {
    // Create temporary controllers for the dialog
    List<Map<String, TextEditingController>> tempLectureControllers = [];

    // Populate from existing lectures if any
    final List<dynamic> existingLectures =
        course['lectures'] as List<dynamic>? ?? [];
    if (existingLectures.isNotEmpty) {
      for (var lecture in existingLectures) {
        tempLectureControllers.add({
          'day': TextEditingController(text: lecture['day']),
          'time': TextEditingController(text: lecture['time']),
          'room': TextEditingController(text: lecture['room']),
        });
      }
    } else {
      // Add one empty row if no lectures exist
      tempLectureControllers.add({
        'day': TextEditingController(text: _selectedDay),
        'time': TextEditingController(),
        'room': TextEditingController(),
      });
    }

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Manage Lectures for ${course['code']}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < tempLectureControllers.length; i++)
                      Padding(
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
                                value: tempLectureControllers[i]['day']!.text,
                                items:
                                    _weekDays.map((String day) {
                                      return DropdownMenuItem<String>(
                                        value: day,
                                        child: Text(day),
                                      );
                                    }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    tempLectureControllers[i]['day']!.text =
                                        newValue!;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Time field
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: tempLectureControllers[i]['time'],
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
                                controller: tempLectureControllers[i]['room'],
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
                                setState(() {
                                  tempLectureControllers.removeAt(i);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add Lecture'),
                      onPressed: () {
                        setState(() {
                          tempLectureControllers.add({
                            'day': TextEditingController(text: _selectedDay),
                            'time': TextEditingController(),
                            'room': TextEditingController(),
                          });
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // Dispose temporary controllers
                    for (var controllers in tempLectureControllers) {
                      controllers['day']?.dispose();
                      controllers['time']?.dispose();
                      controllers['room']?.dispose();
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Create lectures list from controllers
                    final List<Map<String, dynamic>> updatedLectures = [];
                    for (var controller in tempLectureControllers) {
                      if ((controller['room']?.text.isNotEmpty ?? false) &&
                          (controller['time']?.text.isNotEmpty ?? false)) {
                        updatedLectures.add({
                          'day': controller['day']?.text,
                          'time': controller['time']?.text,
                          'room': controller['room']?.text,
                        });
                      }
                    }

                    // Update course in Firestore
                    try {
                      await FirebaseFirestore.instance
                          .collection('courses')
                          .doc(course['id'].toString())
                          .update({'lectures': updatedLectures});

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Lectures updated successfully!'),
                        ),
                      );

                      // Refresh course list
                      await _loadCourses();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error updating lectures: $e')),
                      );
                    }

                    // Dispose temporary controllers
                    for (var controllers in tempLectureControllers) {
                      controllers['day']?.dispose();
                      controllers['time']?.dispose();
                      controllers['room']?.dispose();
                    }

                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade900,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save Lectures'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Build instructors tab
  Widget _buildInstructorsTab() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // Inner tab bar for Instructors
          TabBar(
            labelColor: Colors.red.shade900,
            tabs: const [
              Tab(text: 'All Instructors'),
              Tab(text: 'Add Instructor'),
            ],
          ),

          // Inner tab views
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

  // Build instructors list
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
        padding: const EdgeInsets.all(8.0),
        itemCount: _instructors.length,
        itemBuilder: (context, index) {
          final instructor = _instructors[index];

          // Convert assignedCourses to a list
          List<String> assignedCourseIds = [];
          if (instructor['assignedCourses'] != null) {
            assignedCourseIds = List<String>.from(
              instructor['assignedCourses'],
            );
          }

          // Get course names for display
          List<String> courseNames = [];
          for (var courseId in assignedCourseIds) {
            final course = _courses.firstWhere(
              (c) => c['id'].toString() == courseId,
              orElse: () => {'code': 'Unknown'},
            );
            courseNames.add(course['code'] ?? 'Unknown');
          }

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
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
                  Text('Email: ${instructor['email']}'),
                  Text(
                    'Academic Degree: ${instructor['academicDegree'] ?? 'N/A'}',
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.book, color: Colors.blue),
                    onPressed:
                        () => _showAssignCoursesToInstructorDialog(instructor),
                    tooltip: 'Assign Courses',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteInstructorDialog(instructor),
                    tooltip: 'Delete Instructor',
                  ),
                ],
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Contact Information:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('Phone: ${instructor['phone'] ?? 'N/A'}'),
                      Text('Address: ${instructor['address'] ?? 'N/A'}'),
                      const SizedBox(height: 8),
                      const Text(
                        'Assigned Courses:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (courseNames.isEmpty)
                        const Text(
                          'No courses assigned yet',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          children:
                              courseNames
                                  .map(
                                    (code) => Chip(
                                      label: Text(code),
                                      backgroundColor: Colors.blue.shade100,
                                    ),
                                  )
                                  .toList(),
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

  // Build add instructor form
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
                // Store the complete number in the controller when form is submitted
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
                labelText: 'Academic Degree (e.g., PhD, MSc)',
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

            // Assign Courses Section
            if (_courses.isNotEmpty) ...[
              const Text(
                'Assign Courses (Optional)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...List.generate(_courses.length, (index) {
                final course = _courses[index];
                return CheckboxListTile(
                  title: Text('${course['code']} - ${course['name']}'),
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
                );
              }),
              const SizedBox(height: 16),
            ],

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

  // Show dialog to assign courses to an instructor
  void _showAssignCoursesToInstructorDialog(Map<String, dynamic> instructor) {
    // Convert instructor's assignedCourses to a list of strings if it exists
    List<String> currentAssignedCourses = [];
    if (instructor['assignedCourses'] != null) {
      currentAssignedCourses = List<String>.from(instructor['assignedCourses']);
    }

    List<String> selectedCourses = List.from(currentAssignedCourses);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Assign Courses to ${instructor['name']}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Select courses to assign:'),
                    const SizedBox(height: 16),
                    ..._courses.map((course) {
                      final courseId = course['id'].toString();
                      final isAssigned = selectedCourses.contains(courseId);

                      return CheckboxListTile(
                        title: Text('${course['code']} - ${course['name']}'),
                        value: isAssigned,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              selectedCourses.add(courseId);
                            } else {
                              selectedCourses.remove(courseId);
                            }
                          });
                        },
                      );
                    }).toList(),
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
                    try {
                      // Update the instructor's assignedCourses
                      await FirebaseFirestore.instance
                          .collection('instructors')
                          .doc(instructor['id'])
                          .update({'assignedCourses': selectedCourses});

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Courses assigned successfully!'),
                        ),
                      );

                      // Refresh instructor list
                      await _loadInstructors();
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error assigning courses: $e')),
                      );
                    }
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.green),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Show confirmation dialog for deleting an instructor
  void _showDeleteInstructorDialog(Map<String, dynamic> instructor) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Instructor'),
            content: Text(
              'Are you sure you want to delete "${instructor['name']}"? This action cannot be undone.',
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

  // Delete an instructor
  Future<void> _deleteInstructor(String instructorId) async {
    try {
      final firestoreService = FirestoreService();
      await firestoreService.deleteInstructor(int.parse(instructorId));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Instructor deleted successfully!')),
      );

      // Refresh the instructor list
      await _loadInstructors();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting instructor: $e')));
    }
  }

  // Add Instructor method
  Future<void> _addInstructor() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final firestoreService = FirestoreService();
      await firestoreService.addNewInstructor(
        id: int.parse(_instructorIdController.text),
        name: _instructorNameController.text,
        email: _instructorEmailController.text,
        password: _instructorPasswordController.text,
        phone: _instructorPhoneController.text,
        address: _instructorAddressController.text,
        academicDegree: _instructorDegreeController.text,
        assignedCourses: _selectedCourseIds,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Instructor added successfully!')),
      );

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

      // Refresh the instructor list
      await _loadInstructors();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error adding instructor: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

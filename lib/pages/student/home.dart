import 'dashboard.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'course_registration.dart';
import 'profile.dart';
import 'schedule.dart';
import 'payment.dart';
import 'attendance.dart';
import 'results.dart';
import '../services/online_services.dart';
import '../services/announcements.dart';
import '../support/support_help_desk.dart';
import '../chat/chat_page.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import 'package:percent_indicator/percent_indicator.dart';

class HomePage extends StatefulWidget {
  final String? userType;
  final Map<String, dynamic>? user;

  const HomePage({super.key, this.userType, this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 2;
  Map<String, dynamic>? _studentData;

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    if (widget.userType == 'student' && widget.user != null) {
      try {
        final studentDoc =
            await FirebaseFirestore.instance
                .collection('students')
                .doc(widget.user!['id'])
                .get();

        if (studentDoc.exists) {
          final data = studentDoc.data();

          if (data != null) {
            // Merge the user data from login with the Firestore data
            final mergedData = {
              ...data,
              'name': widget.user!['name'] ?? data['name'],
              'email': widget.user!['email'] ?? data['email'],
              'level': widget.user!['level'] ?? data['level'],
              'major': widget.user!['major'] ?? data['major'],
              'collegeName': widget.user!['collegeName'] ?? data['collegeName'],
              'credits': widget.user!['credits'] ?? data['credits'],
              'gpa': widget.user!['gpa'] ?? data['gpa'],
              'phone': widget.user!['phone'] ?? data['phone'],
              'address': widget.user!['address'] ?? data['address'],
            };

            setState(() {
              _studentData = mergedData;
            });
          }
        } else {
          // If document not found, use the data from login
          setState(() {
            _studentData = widget.user;
          });
        }
      } catch (e) {
        // If there's an error, use the data from login
        setState(() {
          _studentData = widget.user;
        });
      }
    }
  }

  List<Widget> get _pages => [
    const DashboardPage(),
    const OnlineServicesPage(),
    HomeContent(studentData: _studentData),
    ProfilePage(studentData: _studentData),
    const ChatPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Image.asset('assets/cic_logo.png', height: 55)],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.red.shade900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assets/profile.png'),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _studentData?['name'] ?? widget.user?['name'] ?? 'User',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(Icons.home, 'Home', context),
            _buildDrawerItem(Icons.person, 'Profile', context),
            _buildDrawerItem(Icons.school, 'Courses', context),
            _buildDrawerItem(Icons.calendar_today, 'Timetable', context),
            _buildDrawerItem(Icons.credit_card, 'Fees Payment', context),
            _buildDrawerItem(Icons.chat, 'AI Assistant', context),
            _buildDrawerItem(Icons.logout, 'Logout', context),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.white,
        color: Colors.red.shade900,
        buttonBackgroundColor: Colors.red.shade900,
        height: 60,
        animationDuration: const Duration(milliseconds: 300),
        animationCurve: Curves.easeInOut,
        index: _selectedIndex,
        items: const [
          Icon(Icons.dashboard_outlined, size: 30, color: Colors.white),
          Icon(Icons.calendar_month_outlined, size: 30, color: Colors.white),
          Icon(Icons.home_outlined, size: 35, color: Colors.white),
          Icon(Icons.person_outline, size: 30, color: Colors.white),
          Icon(Icons.chat_outlined, size: 30, color: Colors.white),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        if (title == 'Home') {
          setState(() {
            _selectedIndex = 2;
          });
        } else if (title == 'Profile') {
          setState(() {
            _selectedIndex = 3;
          });
        } else if (title == 'Courses') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => CourseRegistration(
                    studentId: _studentData?['id']?.toString(),
                  ),
            ),
          );
        } else if (title == 'AI Assistant') {
          setState(() {
            _selectedIndex = 4;
          });
        } else if (title == 'Logout') {
          Navigator.pushReplacementNamed(context, '/login');
        }
      },
    );
  }
}

class HomeContent extends StatelessWidget {
  final Map<String, dynamic>? studentData;

  const HomeContent({super.key, this.studentData});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card with Academic Info
            FadeInDown(
              duration: const Duration(milliseconds: 600),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red.shade900, Colors.red.shade800],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Top part with user info
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(50),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: const CircleAvatar(
                              radius: 35,
                              backgroundImage: AssetImage('assets/profile.png'),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.waving_hand_rounded,
                                      color: Colors.amber,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      'Welcome Back!',
                                      style: TextStyle(
                                        color: Colors.white.withAlpha(200),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  studentData?['name']?.split(' ')[0] ??
                                      'Student',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withAlpha(50),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Text(
                                        'ID: ${studentData?['id'] ?? 'N/A'}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withAlpha(50),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Text(
                                        'Level: ${studentData?['level'] ?? 'N/A'}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Bottom part with academic info
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildAcademicInfoItem(
                            'GPA',
                            studentData?['gpa']?.toString() ?? 'N/A',
                            Icons.school_rounded,
                            Colors.blue,
                          ),
                          _buildAcademicInfoItem(
                            'Credits',
                            studentData?['credits']?.toString() ?? 'N/A',
                            Icons.credit_score_rounded,
                            Colors.green,
                          ),
                          _buildAcademicInfoItem(
                            'Major',
                            studentData?['major']?.toString() ?? 'N/A',
                            Icons.book_rounded,
                            Colors.orange,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Quick Actions
            FadeInLeft(
              duration: const Duration(milliseconds: 800),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.touch_app,
                          size: 16,
                          color: Colors.red.shade900,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Tap to access',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red.shade900,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            FadeInUp(
              duration: const Duration(milliseconds: 800),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                childAspectRatio: 0.85,
                children: [
                  _buildQuickActionCard(
                    'Schedule',
                    Icons.calendar_month_rounded,
                    Colors.blue,
                    context,
                    SchedulePage(userData: studentData),
                  ),
                  _buildQuickActionCard(
                    'Attending',
                    Icons.fact_check_rounded,
                    Colors.green,
                    context,
                    const AttendancePage(),
                  ),
                  _buildQuickActionCard(
                    'Register',
                    Icons.app_registration_rounded,
                    Colors.red.shade900,
                    context,
                    CourseRegistration(
                      studentId: studentData?['id']?.toString(),
                    ),
                  ),
                  _buildQuickActionCard(
                    'Support',
                    Icons.support_agent_rounded,
                    Colors.teal,
                    context,
                    SupportHelpDeskPage(userData: studentData),
                  ),
                  _buildQuickActionCard(
                    'Payment',
                    Icons.payments_rounded,
                    Colors.orange,
                    context,
                    const PaymentPage(),
                  ),
                  _buildQuickActionCard(
                    'Results',
                    Icons.grading_rounded,
                    Colors.purple,
                    context,
                    const ResultsPage(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Announcements Section
            FadeInRight(
              duration: const Duration(milliseconds: 800),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.campaign_rounded,
                        color: Colors.red.shade900,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Announcements',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AnnouncementsPage(),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: Colors.red.shade900,
                    ),
                    label: Text(
                      'View All',
                      style: TextStyle(color: Colors.red.shade900),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Dynamic Announcements from Firestore
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('announcements')
                      .orderBy('date', descending: true)
                      .limit(3)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(
                        color: Colors.red.shade900,
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red.shade300,
                          size: 48,
                        ),
                        const SizedBox(height: 10),
                        const Text('Error loading announcements'),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.announcement_outlined,
                            color: Colors.grey.shade400,
                            size: 48,
                          ),
                          const SizedBox(height: 10),
                          const Text('No announcements available'),
                        ],
                      ),
                    ),
                  );
                }

                // Build announcement cards from Firestore data
                return FadeInUp(
                  duration: const Duration(milliseconds: 1000),
                  child: Column(
                    children:
                        snapshot.data!.docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;

                          // Convert Timestamp to DateTime
                          final date =
                              data['date'] is Timestamp
                                  ? (data['date'] as Timestamp).toDate()
                                  : DateTime.now();

                          // Format date as string
                          final formattedDate = _formatDate(date);

                          return Column(
                            children: [
                              _buildAnnouncementCard(
                                data['title'] ?? 'Untitled',
                                data['content'] ?? '',
                                formattedDate,
                                data['category'] ?? 'General',
                              ),
                              const SizedBox(height: 10),
                            ],
                          );
                        }).toList(),
                  ),
                );
              },
            ),

            // Add some space at the bottom
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAcademicInfoItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withAlpha(30),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    BuildContext context,
    Widget targetPage,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => targetPage),
          );
        },
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, color.withAlpha(30)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 30, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnnouncementCard(
    String title,
    String content,
    String time, [
    String category = 'General',
  ]) {
    // Choose icon based on category
    IconData categoryIcon = Icons.announcement;
    Color categoryColor = Colors.red.shade900;

    switch (category.toLowerCase()) {
      case 'academic':
        categoryIcon = Icons.school;
        categoryColor = Colors.blue;
        break;
      case 'event':
        categoryIcon = Icons.event;
        categoryColor = Colors.green;
        break;
      case 'urgent':
        categoryIcon = Icons.priority_high;
        categoryColor = Colors.orange;
        break;
      case 'exam':
        categoryIcon = Icons.assignment;
        categoryColor = Colors.purple;
        break;
      default:
        categoryIcon = Icons.announcement;
        categoryColor = Colors.red.shade900;
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: categoryColor.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(categoryIcon, color: categoryColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            time,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: categoryColor.withAlpha(30),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              category,
                              style: TextStyle(
                                fontSize: 10,
                                color: categoryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d, y').format(date);
    }
  }
}

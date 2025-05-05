import 'package:cic_hub/pages/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'course_registration.dart';
import 'profile.dart';
import 'schedule.dart';
import 'payment.dart';
import 'attendance.dart';
import 'results.dart';
import 'online_services.dart';
import 'announcements.dart';
import 'support_help_desk.dart';
import 'package:intl/intl.dart';

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
            // Welcome Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.shade900, Colors.red.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
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
                        const Text(
                          'Welcome Back!',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        Text(
                          studentData?['name']?.split(' ')[0] ?? 'Student',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            'ID: ${studentData?['id'] ?? 'N/A'}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 15),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              childAspectRatio: 1.5,
              children: [
                _buildQuickActionCard(
                  'Schedule',
                  Icons.calendar_today,
                  Colors.blue,
                  context,
                  SchedulePage(userData: studentData),
                ),
                _buildQuickActionCard(
                  'Attendance',
                  Icons.check_circle,
                  Colors.green,
                  context,
                  const AttendancePage(),
                ),
                _buildQuickActionCard(
                  'Registration',
                  Icons.menu_book,
                  Colors.red.shade900,
                  context,
                  CourseRegistration(studentId: studentData?['id']?.toString()),
                ),
                _buildQuickActionCard(
                  'Support & Help',
                  Icons.support_agent,
                  Colors.teal,
                  context,
                  SupportHelpDeskPage(userData: studentData),
                ),
                _buildQuickActionCard(
                  'Payment',
                  Icons.payment,
                  Colors.orange,
                  context,
                  const PaymentPage(),
                ),
                _buildQuickActionCard(
                  'Results',
                  Icons.grade,
                  Colors.purple,
                  context,
                  const ResultsPage(),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // Announcements Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Announcements',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AnnouncementsPage(),
                      ),
                    );
                  },
                  child: Text(
                    'View All',
                    style: TextStyle(color: Colors.red.shade900),
                  ),
                ),
              ],
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
                  return const Center(
                    child: Text('Error loading announcements'),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(child: Text('No announcements available')),
                  );
                }

                // Build announcement cards from Firestore data
                return Column(
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
                            ),
                            const SizedBox(height: 10),
                          ],
                        );
                      }).toList(),
                );
              },
            ),
          ],
        ),
      ),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnnouncementCard(String title, String content, String time) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.announcement, color: Colors.red.shade900, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 8),
            Text(
              time,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
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

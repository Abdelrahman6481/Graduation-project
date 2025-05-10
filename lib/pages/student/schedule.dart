import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SchedulePage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final String userType;

  const SchedulePage({super.key, this.userData, this.userType = 'student'});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  DateTime selectedDate = DateTime.now();
  String selectedDay = DateFormat('EEEE').format(DateTime.now());
  bool _isLoading = true;
  List<Map<String, dynamic>> _schedules = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: days.length, vsync: this);
    int initialIndex = days.indexOf(selectedDay);
    if (initialIndex != -1) {
      _tabController.index = initialIndex;
    }
    _fetchScheduleData();
  }

  final List<String> days = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
  ];

  // Default icons and colors for subjects
  final Map<String, IconData> subjectIcons = {
    'Mathematics': Icons.calculate,
    'Physics': Icons.science,
    'Computer Science': Icons.computer,
    'English': Icons.menu_book,
    'default': Icons.school,
  };

  final Map<String, Color> subjectColors = {
    'Mathematics': Color(0xFF1E88E5),
    'Physics': Color(0xFF43A047),
    'Computer Science': Color(0xFF8E24AA),
    'English': Color(0xFFEF6C00),
    'default': Color(0xFF607D8B),
  };

  // Quick action card colors from HomePage
  final List<Color> cardColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.indigo,
    Colors.pink,
    Colors.amber,
  ];

  Future<void> _fetchScheduleData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get user's registered courses if we have userData
      if (widget.userData != null) {
        final String userId = widget.userData!['id'].toString();
        List<String> courseIds = [];

        // For students, get registered courses
        if (widget.userType == 'student') {
          final registrationsSnapshot =
              await FirebaseFirestore.instance
                  .collection('courseRegistrations')
                  .where('studentId', isEqualTo: int.tryParse(userId) ?? userId)
                  .where('status', isEqualTo: 'active')
                  .get();

          courseIds =
              registrationsSnapshot.docs
                  .map((doc) => doc['courseId'].toString())
                  .toList();
        }
        // For instructors, get assigned courses
        else if (widget.userType == 'instructor') {
          if (widget.userData!['assignedCourses'] != null) {
            courseIds = List<String>.from(widget.userData!['assignedCourses']);
          }
        }

        // Fetch course details for each registered course
        List<Map<String, dynamic>> schedulesData = [];
        int colorIndex = 0;

        for (String courseId in courseIds) {
          final courseSnapshot =
              await FirebaseFirestore.instance
                  .collection('courses')
                  .doc(courseId)
                  .get();

          if (courseSnapshot.exists) {
            final courseData = courseSnapshot.data()!;

            // Each course can have multiple lectures
            final lectures = courseData['lectures'] as List<dynamic>? ?? [];

            // Assign a color from the cardColors list
            final Color cardColor = cardColors[colorIndex % cardColors.length];
            colorIndex++;

            for (var lecture in lectures) {
              final subject = courseData['name'] ?? 'Unknown Subject';
              final courseCode = courseData['code'] ?? '';
              final professor = courseData['instructor'] ?? 'TBA';
              final day = lecture['day'] ?? '';
              final time = lecture['time'] ?? '';
              final room = lecture['room'] ?? 'TBA';

              // Parse time format like "9:00-10:30" into start and end times
              String startTime = 'TBA';
              String endTime = 'TBA';

              if (time.contains('-')) {
                final timeParts = time.split('-');
                startTime = timeParts[0].trim();
                endTime = timeParts[1].trim();
              }

              // Determine icon and color based on subject
              IconData icon = subjectIcons['default']!;

              // Try to match subject with predefined icons
              for (var key in subjectIcons.keys) {
                if (subject.toLowerCase().contains(key.toLowerCase())) {
                  icon = subjectIcons[key]!;
                  break;
                }
              }

              schedulesData.add({
                'subject': subject,
                'courseCode': courseCode,
                'day': day,
                'startTime': startTime,
                'endTime': endTime,
                'professor': professor,
                'room': room,
                'building': 'CIC',
                'icon': icon,
                'color': cardColor,
                'progress': 0.8, // Default progress
                'type': 'Lecture',
              });
            }
          }
        }

        setState(() {
          _schedules = schedulesData;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching schedule data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get filteredSchedules {
    return _schedules
        .where((schedule) => schedule['day'] == selectedDay)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildDateSelector(),
            _isLoading
                ? Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Colors.red.shade900,
                    ),
                  ),
                )
                : Expanded(child: _buildScheduleList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new schedule logic
        },
        backgroundColor: Colors.red.shade900,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Schedule',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                DateFormat('EEEE, MMMM d').format(selectedDate),
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
          CircleAvatar(
            backgroundColor: Colors.red.shade900,
            child: const Icon(Icons.calendar_today, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index - 3));
          final isSelected =
              DateFormat('dd MMM').format(date) ==
              DateFormat('dd MMM').format(selectedDate);
          final dayName = DateFormat('EEE').format(date);
          final dayNumber = DateFormat('dd').format(date);

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDate = date;
                selectedDay = DateFormat('EEEE').format(date);
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 6),
              width: 60,
              decoration: BoxDecoration(
                color: isSelected ? Colors.red.shade900 : Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color:
                      isSelected ? Colors.red.shade900 : Colors.grey.shade300,
                  width: 1,
                ),
                boxShadow:
                    isSelected
                        ? [
                          BoxShadow(
                            color: Colors.red.shade900.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                        : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayName,
                    style: TextStyle(
                      color: isSelected ? Colors.white70 : Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    dayNumber,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScheduleList() {
    if (filteredSchedules.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: filteredSchedules.length,
      itemBuilder: (context, index) {
        final schedule = filteredSchedules[index];
        return FadeInUp(
          duration: Duration(milliseconds: 300 + (index * 100)),
          child: _buildScheduleCard(schedule),
        );
      },
    );
  }

  Widget _buildScheduleCard(Map<String, dynamic> schedule) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: schedule['color'].withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Schedule detail logic
            },
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: schedule['color'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          schedule['icon'],
                          color: schedule['color'],
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              schedule['subject'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              schedule['courseCode'] ?? schedule['type'],
                              style: TextStyle(
                                color: schedule['color'],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: schedule['color'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          schedule['type'],
                          style: TextStyle(
                            color: schedule['color'],
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildInfoChip(
                        Icons.access_time,
                        '${schedule['startTime']} - ${schedule['endTime']}',
                      ),
                      const SizedBox(width: 15),
                      _buildInfoChip(Icons.location_on, schedule['room']),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.grey[100],
                        child: Icon(
                          Icons.person,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          schedule['professor'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text(
            'No Classes Today',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Enjoy your free time!',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
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

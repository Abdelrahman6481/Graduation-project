import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class ProfilePage extends StatelessWidget {
  final Map<String, dynamic>? studentData;

  const ProfilePage({super.key, this.studentData});

  @override
  Widget build(BuildContext context) {
    // Default values if no data is provided
    final String name = studentData?['name'] ?? 'Student Name';
    final String major = studentData?['major'] ?? 'Computer Science';
    final String email = studentData?['email'] ?? 'student@example.com';
    final String phone = studentData?['phone'] ?? 'Not provided';
    final String address = studentData?['address'] ?? 'Not provided';
    final String college = studentData?['collegeName'] ?? 'CIC';
    final String id = studentData?['id']?.toString() ?? 'Not assigned';
    final int level = studentData?['level'] ?? 1;
    final int credits = studentData?['credits'] ?? 0;
    final double gpa =
        studentData?['gpa'] != null
            ? (studentData!['gpa'] is int
                ? (studentData!['gpa'] as int).toDouble()
                : studentData!['gpa'] as double)
            : 0.0;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.red.shade900),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.red.shade900),
            onPressed: () {
              // Implement settings action
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            FadeInDown(
              duration: Duration(milliseconds: 500),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.red.shade900,
                              width: 3,
                            ),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/profile.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red.shade900,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '$major Student',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStatusCard('GPA', gpa.toStringAsFixed(2)),
                        SizedBox(width: 20),
                        _buildStatusCard('Level', level.toString()),
                        SizedBox(width: 20),
                        _buildStatusCard('Credits', credits.toString()),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),

            // Information Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Personal Information',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  FadeInLeft(
                    child: _buildInfoCard(
                      Icons.school,
                      'Academic Information',
                      [
                        {'College': college},
                        {'Major': major},
                        {'Student ID': id},
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  FadeInRight(
                    child: _buildInfoCard(
                      Icons.location_on,
                      'Contact Information',
                      [
                        {'Email': email},
                        {'Phone': phone},
                        {'Address': address},
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  FadeInLeft(
                    child: _buildInfoCard(
                      Icons.school_outlined,
                      'Academic Status',
                      [
                        {'Current Level': 'Level $level'},
                        {'Total Credits': '$credits Credits'},
                        {'Current GPA': gpa.toStringAsFixed(2)},
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String title, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade900,
            ),
          ),
          SizedBox(height: 5),
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    IconData icon,
    String title,
    List<Map<String, String>> items,
  ) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.red.shade900, size: 24),
              SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 15),
          ...items.map(
            (item) => _buildInfoItem(item.keys.first, item.values.first),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          Text(
            value,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

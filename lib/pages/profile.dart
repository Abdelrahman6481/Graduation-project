import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            FadeInDown(
              child: Container(
                padding: EdgeInsets.all(20),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.red.shade900,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 48,
                        backgroundImage: AssetImage('assets/profile.png'),
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Abdelrahman',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'abdelrahman_m16481@cic-cairo.com',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    SizedBox(height: 15),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  FadeInLeft(
                    child: ProfileCard(
                      icon: Icons.school,
                      label: 'College',
                      value: 'Computer Science',
                    ),
                  ),
                  FadeInRight(
                    child: ProfileCard(
                      icon: Icons.code,
                      label: 'Major',
                      value: 'Software Engineering',
                    ),
                  ),
                  FadeInLeft(
                    child: ProfileCard(
                      icon: Icons.badge,
                      label: 'Student ID',
                      value: '16481',
                    ),
                  ),
                  FadeInRight(
                    child: ProfileCard(
                      icon: Icons.calendar_today,
                      label: 'Year',
                      value: '3rd Year',
                    ),
                  ),
                  FadeInLeft(
                    child: ProfileCard(
                      icon: Icons.location_on,
                      label: 'Campus',
                      value: 'New Cairo',
                    ),
                  ),
                  FadeInRight(
                    child: ProfileCard(
                      icon: Icons.phone,
                      label: 'Phone',
                      value: '+20 123 456 7890',
                      showEdit: true,
                    ),
                  ),
                  FadeInLeft(
                    child: ProfileCard(
                      icon: Icons.lock,
                      label: 'Password',
                      value: '••••••••',
                      showEdit: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool showEdit;

  const ProfileCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.showEdit = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.red.shade100,
          child: Icon(icon, color: Colors.red.shade900, size: 28),
        ),
        title: Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(value, style: TextStyle(color: Colors.black54, fontSize: 14)),
        trailing: showEdit
            ? IconButton(
          icon: Icon(Icons.edit, color: Colors.red.shade900),
          onPressed: () {
            // Implement password change or phone number update logic
          },
        )
            : null,
      ),
    );
  }
}

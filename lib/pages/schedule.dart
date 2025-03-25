import 'package:flutter/material.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red.shade900,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Schedule',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildScheduleCard('Math', 'Sunday', '10:00 AM - 12:00 PM'),
                  _buildScheduleCard('Physics', 'Monday', '12:30 PM - 2:30 PM'),
                  _buildScheduleCard('Computer Science', 'Wednesday', '9:00 AM - 11:00 AM'),
                  _buildScheduleCard('English', 'Thursday', '1:00 PM - 3:00 PM'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard(String subject, String day, String time) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        contentPadding: EdgeInsets.all(16.0),
        title: Text(
          subject,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text('$day - $time',
            style: TextStyle(fontSize: 16)),
        leading: Icon(Icons.schedule, color: Colors.red.shade900),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class PreLoginPage extends StatelessWidget {
  const PreLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDEED5), // لون الخلفية
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/cic_logo.png', // تأكد من إضافة اللوجو داخل assets
              width: 200,
            ),
            const SizedBox(height: 20),
            const Text(
              'CANADIAN INTERNATIONAL COLLEGE',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const Text(
              'THE FUTURE IS YOURS',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCampusButton(context, 'New Cairo'),
                const SizedBox(width: 20),
                _buildCampusButton(context, 'Zayed'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampusButton(BuildContext context, String text) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: () {
        // يمكنك تحديد الإجراء المطلوب هنا عند الضغط على الزر
      },
      child: Text(text),
    );
  }
}

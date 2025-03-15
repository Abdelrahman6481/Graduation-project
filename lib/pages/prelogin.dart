import 'package:cic_hub/pages/home.dart';
import 'package:flutter/material.dart';
import 'login.dart'; // استدعاء صفحة تسجيل الدخول

class PreLoginPage extends StatelessWidget {
  const PreLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD7E9D3), // لون الخلفية
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/cic_logo.png', // تأكد من وجود الصورة في مجلد assets
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
                _buildCampusButton(context, 'New Cairo', const HomePage()), // لا يقوم بفتح صفحة
                const SizedBox(width: 20),
                _buildCampusButton(context, 'Zayed', const LoginPage()), // ينقلك إلى صفحة تسجيل الدخول
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampusButton(BuildContext context, String text, Widget? page) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF8B0000), // لون الزر
        foregroundColor: Colors.white, // لون النص
        padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      onPressed: () {
        if (page != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        }
      },
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18, // تكبير الخط
          fontWeight: FontWeight.bold, // جعل النص سميكًا
        ),
      ),
    );
  }
}
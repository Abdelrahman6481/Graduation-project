import 'package:flutter/material.dart';
import 'package:cic_hub/pages/home.dart';
import 'login.dart';
import 'instructor_login.dart';

class PreLoginPage extends StatelessWidget {
  const PreLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Design
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.red.shade900.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.red.shade900.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  _buildLogoSection(),
                  const Spacer(flex: 1), // Added flex: 1
                  _buildWelcomeText(),
                  const SizedBox(height: 30),
                  _buildCampusSection(context),
                  const Spacer(flex: 1), // Added flex: 1
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        // Logo
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 10,
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Image.asset('assets/cic_logo.png', width: 120, height: 120),
        ),
        const SizedBox(height: 40),
        // College Name
        const Text(
          'CANADIAN',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: Colors.black87,
          ),
        ),
        const Text(
          'INTERNATIONAL COLLEGE',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            letterSpacing: 4,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeText() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.shade900,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'THE FUTURE IS YOURS',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildCampusSection(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Select Your Campus',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 30),
        Row(
          children: [
            Expanded(
              child: _buildCampusCard(
                context,
                'New Cairo',
                const HomePage(),
                Icons.location_city,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildCampusCard(
                context,
                'Sheikh Zayed',
                const LoginPage(),
                Icons.apartment,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCampusCard(
    BuildContext context,
    String campusName,
    Widget page,
    IconData icon,
  ) {
    return GestureDetector(
      onTap: () {
        if (campusName == 'New Cairo') {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          Navigator.pushReplacementNamed(context, '/login');
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 5,
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: Colors.red.shade900.withOpacity(0.1),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 50, color: Colors.red.shade900),
            const SizedBox(height: 15),
            Text(
              campusName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Tap to select',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pushNamed(context, '/login');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade900,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.login),
        label: const Text('Login to System', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
